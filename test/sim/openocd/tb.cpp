#include <iostream>
#include <fstream>
#include <cstdint>
#include <string>
#include <algorithm>
#include <stdio.h>

#include <unistd.h>
#include <sys/socket.h>
#include <netinet/in.h>

// Device-under-test model generated by CXXRTL:
#include "dut.cpp"
#include <backends/cxxrtl/cxxrtl_vcd.h>

static const unsigned int MEM_SIZE = 16 * 1024 * 1024;
uint8_t mem[MEM_SIZE];

static const unsigned int IO_BASE = 0x80000000;
static const unsigned int IO_MASK = 0xffffff00;
enum {
	IO_PRINT_CHAR = 0x000,
	IO_PRINT_U32  = 0x004,
	IO_EXIT       = 0x008,
	IO_MTIME      = 0x100,
	IO_MTIMEH     = 0x104,
	IO_MTIMECMP   = 0x108,
	IO_MTIMECMPH  = 0x10c
};

static const int TCP_BUF_SIZE = 256;

const char *help_str =
"Usage: tb [vcdfile] [--dump start end] [--cycles n] [--port n]\n"
"    vcdfile           : Path to dump waveforms to\n"
"    --dump start end  : Print out memory contents between start and end (exclusive)\n"
"                        after execution finishes. Can be passed multiple times.\n"
"    --cycles n        : Maximum number of cycles to run before exiting.\n"
"                        Default is 0 (no maximum).\n"
"    --port n          : Port number to listen for openocd remote bitbang\n"
;

void exit_help(std::string errtext = "") {
	std::cerr << errtext << help_str;
	exit(-1);
}

int main(int argc, char **argv) {

	bool dump_waves = false;
	std::string waves_path;
	std::vector<std::pair<uint32_t, uint32_t>> dump_ranges;
	int64_t max_cycles = 0;
	uint16_t port = 9824;

	for (int i = 1; i < argc; ++i) {
		std::string s(argv[i]);
		if (i == 1 && s.rfind("--", 0) != 0) {
			// Optional positional argument: vcdfile
			dump_waves = true;
			waves_path = s;
		}
		else if (s == "--dump") {
			if (argc - i < 3)
				exit_help("Option --dump requires 2 arguments\n");
			dump_ranges.push_back(std::pair<uint32_t, uint32_t>(
				std::stoul(argv[i + 1], 0, 0),
				std::stoul(argv[i + 2], 0, 0)
			));;
			i += 2;
		}
		else if (s == "--cycles") {
			if (argc - i < 2)
				exit_help("Option --cycles requires an argument\n");
			max_cycles = std::stol(argv[i + 1], 0, 0);
			i += 1;
		}
		else if (s == "--port") {
			if (argc - i < 2)
				exit_help("Option --port requires an argument\n");
			port = std::stol(argv[i + 1], 0, 0);
			i += 1;
		}
		else {
			std::cerr << "Unrecognised argument " << s << "\n";
			exit_help("");
		}
	}


	int server_fd, sock_fd;
	struct sockaddr_in sock_addr;
	int sock_opt = 1;
	socklen_t sock_addr_len = sizeof(sock_addr);
	char txbuf[TCP_BUF_SIZE], rxbuf[TCP_BUF_SIZE];
	int rx_ptr = 0, rx_remaining = 0, tx_ptr = 0;

	server_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (server_fd == 0) {
		fprintf(stderr, "socket creation failed\n");
		exit(-1);
	}

	int setsockopt_rc = setsockopt(
		server_fd, SOL_SOCKET, SO_REUSEADDR | SO_REUSEPORT,
		&sock_opt, sizeof(sock_opt)
	);

	if (setsockopt_rc) {
		fprintf(stderr, "setsockopt failed\n");
		exit(-1);
	}

	sock_addr.sin_family = AF_INET;
	sock_addr.sin_addr.s_addr = INADDR_ANY;
	sock_addr.sin_port = htons(port);
	if (bind(server_fd, (struct sockaddr *)&sock_addr, sizeof(sock_addr)) < 0) {
		fprintf(stderr, "bind failed\n");
		exit(-1);
	}

	printf("Waiting for connection on port %u\n", port);
	if (listen(server_fd, 3) < 0) {
		fprintf(stderr, "listen failed\n");
		exit(-1);
	}
	sock_fd = accept(server_fd, (struct sockaddr *)&sock_addr, &sock_addr_len);
	if (sock_fd < 0) {
		fprintf(stderr, "accept failed\n");
		exit(-1);
	}
	printf("Connected\n");

	cxxrtl_design::p_tb top;

	std::fill(std::begin(mem), std::end(mem), 0);

	std::ofstream waves_fd;
	cxxrtl::vcd_writer vcd;
	if (dump_waves) {
		waves_fd.open(waves_path);
		cxxrtl::debug_items all_debug_items;
		top.debug_info(all_debug_items);
		vcd.timescale(1, "us");
		vcd.add(all_debug_items);
	}

	bool bus_trans = false;
	bool bus_write = false;
	bool bus_trans_i = false;
	uint32_t bus_addr_i = 0;
	uint32_t bus_addr = 0;
	uint8_t bus_size = 0;
	// Never generate bus stalls
	top.p_i__hready.set<bool>(true);
	top.p_d__hready.set<bool>(true);

	uint64_t mtime = 0;
	uint64_t mtimecmp = 0;

	// Reset + initial clock pulse
	top.step();
	top.p_clk.set<bool>(true);
	top.p_tck.set<bool>(true);
	top.step();
	top.p_clk.set<bool>(false);
	top.p_tck.set<bool>(false);
	top.p_trst__n.set<bool>(true);
	top.p_rst__n.set<bool>(true);
	top.step();
	top.step(); // workaround for github.com/YosysHQ/yosys/issues/2780

	for (int64_t cycle = 0; cycle < max_cycles || max_cycles == 0; ++cycle) {
		top.p_clk.set<bool>(false);
		top.step();
		if (dump_waves)
			vcd.sample(cycle * 2);
		top.p_clk.set<bool>(true);
		top.step();
		top.step(); // workaround for github.com/YosysHQ/yosys/issues/2780

		// Most bitbang commands complete in one cycle (e.g. TCK/TMS/TDI
		// writes) but reads take 0 cycles, step=false.
		bool got_exit_cmd = false;
		bool step = false;
		while (!step) {
			if (rx_remaining > 0) {
				char c = rxbuf[rx_ptr++];
				--rx_remaining;

				if (c == 'r' || c == 's') {
					top.p_trst__n.set<bool>(true);
					step = true;
				}
				else if (c == 't' || c == 'u') {
					top.p_trst__n.set<bool>(false);
				}
				else if (c >= '0' && c <= '7') {
					int mask = c - '0';
					top.p_tck.set<bool>(mask & 0x4);
					top.p_tms.set<bool>(mask & 0x2);
					top.p_tdi.set<bool>(mask & 0x1);
					step = true;
				}
				else if (c == 'R') {
					txbuf[tx_ptr++] = top.p_tdo.get<bool>() ? '1' : '0';
					if (tx_ptr >= TCP_BUF_SIZE || rx_remaining == 0) {
						send(sock_fd, txbuf, tx_ptr, 0);
						tx_ptr = 0;
					}
				}
				else if (c == 'Q') {
					printf("OpenOCD sent quit command\n");
					got_exit_cmd = true;
					step = true;
				}
			}
			else {
				// Potentially the last command was not a read command, but
				// OpenOCD is still waiting for a last response from its
				// last command packet before it sends us any more, so now is
				// the time to flush TX.
				if (tx_ptr > 0) {
					send(sock_fd, txbuf, tx_ptr, 0);
					tx_ptr = 0;
				}	
				rx_ptr = 0;
				rx_remaining = read(sock_fd, &rxbuf, TCP_BUF_SIZE);
			}
		}

		// Default update logic for mtime, mtimecmp
		++mtime;
		top.p_timer__irq.set<bool>(mtime >= mtimecmp);

		if (top.p_d__hready.get<bool>()) {
			// Clear bus error by default
			top.p_d__hresp.set<bool>(false);
			// Handle current data phase
			uint32_t rdata = 0;
			bool bus_err = false;
			if (bus_trans && bus_write) {
				uint32_t wdata = top.p_d__hwdata.get<uint32_t>();
				if (bus_addr <= MEM_SIZE - 4u) {
					unsigned int n_bytes = 1u << bus_size;
					// Note we are relying on hazard3's byte lane replication
					for (unsigned int i = 0; i < n_bytes; ++i) {
						mem[bus_addr + i] = wdata >> (8 * i) & 0xffu;
					}
				}
				else if (bus_addr == IO_BASE + IO_PRINT_CHAR) {
					putchar(wdata);
				}
				else if (bus_addr == IO_BASE + IO_PRINT_U32) {
					printf("%08x\n", wdata);
				}
				else if (bus_addr == IO_BASE + IO_EXIT) {
					printf("CPU requested halt. Exit code %d\n", wdata);
					printf("Ran for %ld cycles\n", cycle + 1);
					break;
				}
				else if (bus_addr == IO_BASE + IO_MTIME) {
					mtime = (mtime & 0xffffffff00000000u) | wdata;
				}
				else if (bus_addr == IO_BASE + IO_MTIMEH) {
					mtime = (mtime & 0x00000000ffffffffu) | ((uint64_t)wdata << 32);
				}
				else if (bus_addr == IO_BASE + IO_MTIMECMP) {
					mtimecmp = (mtimecmp & 0xffffffff00000000u) | wdata;
				}
				else if (bus_addr == IO_BASE + IO_MTIMECMPH) {
					mtimecmp = (mtimecmp & 0x00000000ffffffffu) | ((uint64_t)wdata << 32);
				}
				else {
					bus_err = true;
				}
			}
			else if (bus_trans && !bus_write) {
				if (bus_addr <= MEM_SIZE) {
					bus_addr &= ~0x3u;
					rdata =
						(uint32_t)mem[bus_addr] |
						mem[bus_addr + 1] << 8 |
						mem[bus_addr + 2] << 16 |
						mem[bus_addr + 3] << 24;
				}
				else if (bus_addr == IO_BASE + IO_MTIME) {
					rdata = mtime;
				}
				else if (bus_addr == IO_BASE + IO_MTIMEH) {
					rdata = mtime >> 32;
				}
				else if (bus_addr == IO_BASE + IO_MTIMECMP) {
					rdata = mtimecmp;
				}
				else if (bus_addr == IO_BASE + IO_MTIMECMPH) {
					rdata = mtimecmp >> 32;
				}
				else {
					bus_err = true;
				}
			}
			if (bus_err) {
				// Phase 1 of error response
				top.p_d__hready.set<bool>(false);
				top.p_d__hresp.set<bool>(true);
			}
			top.p_d__hrdata.set<uint32_t>(rdata);

			// Progress current address phase to data phase
			bus_trans = top.p_d__htrans.get<uint8_t>() >> 1;
			bus_write = top.p_d__hwrite.get<bool>();
			bus_size = top.p_d__hsize.get<uint8_t>();
			bus_addr = top.p_d__haddr.get<uint32_t>();
		}
		else {
			// hready=0. Currently this only happens when we're in the first
			// phase of an error response, so go to phase 2.
			top.p_d__hready.set<bool>(true);
		}

		if (top.p_i__hready.get<bool>()) {
			top.p_i__hresp.set<bool>(false);
			if (bus_trans_i) {
				bus_addr_i &= ~0x3u;
				if (bus_addr_i <= MEM_SIZE - 4u) {
					top.p_i__hrdata.set<uint32_t>(
						(uint32_t)mem[bus_addr_i] |
						mem[bus_addr_i + 1] << 8 |
						mem[bus_addr_i + 2] << 16 |
						mem[bus_addr_i + 3] << 24
					);
				}
				else {
					top.p_i__hready.set<bool>(false);
					top.p_i__hresp.set<bool>(true);
				}
			}
			bus_trans_i = top.p_i__htrans.get<uint8_t>() >> 1;
			bus_addr_i = top.p_i__haddr.get<uint32_t>();
		}
		else {
			top.p_i__hready.set<bool>(true);
		}

		if (dump_waves) {
			// The extra step() is just here to get the bus responses to line up nicely
			// in the VCD (hopefully is a quick update)
			top.step();
			vcd.sample(cycle * 2 + 1);
			waves_fd << vcd.buffer;
			vcd.buffer.clear();
		}

		if (cycle + 1 == max_cycles)
			printf("Max cycles reached\n");
		if (got_exit_cmd)
			break;
	}

	close(sock_fd);

	for (auto r : dump_ranges) {
		printf("Dumping memory from %08x to %08x:\n", r.first, r.second);
		for (int i = 0; i < r.second - r.first; ++i)
			printf("%02x%c", mem[r.first + i], i % 16 == 15 ? '\n' : ' ');
		printf("\n");
	}

	return 0;
}
