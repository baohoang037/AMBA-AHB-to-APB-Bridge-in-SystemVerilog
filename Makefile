##################################################################################################
# Makefile mô phỏng SystemVerilog Testbench + SVA + Coverage với QuestaSim
# Project: AHB to APB Bridge Verification
##################################################################################################

SHELL := /bin/bash

# ====================================================================================
# NẠP CẤU HÌNH
# ====================================================================================
ifeq ($(strip $(wildcard config.mk)),)
$(error Lỗi: Không tìm thấy file config.mk!)
endif

include config.mk

# ====================================================================================
# KHAI BÁO ĐƯỜNG DẪN THƯ MỤC
# ====================================================================================
RTL_DIR       = $(PROJ_ROOT)/rtl
TB_DIR        = $(PROJ_ROOT)/tb
SIM_DIR       = $(PROJ_ROOT)/sim
DOCS_DIR      = $(PROJ_ROOT)/docs

# Danh sách include directory giúp giữ nguyên toàn bộ các lệnh `include trong code
INCDIRS       = +incdir+$(RTL_DIR) \
                +incdir+$(TB_DIR) \
                +incdir+$(TB_DIR)/agents/ahb_agent \
                +incdir+$(TB_DIR)/agents/apb_agent \
                +incdir+$(TB_DIR)/env \
                +incdir+$(TB_DIR)/assertions \
                +incdir+$(TB_DIR)/tests

COMPILE_FILE  = $(PROJ_ROOT)/compile.f

# Xử lý macro biên dịch cho Test Case và Assertion
DEFINES       = +define+TEST_NAME=$(TEST)
ifeq ($(ASSERT_OFF), 1)
DEFINES      += +define+ASSERT_OFF
endif

# Cấu hình cờ UVM (khi USE_UVM = 1)
ifeq ($(USE_UVM), 1)
UVM_VLOG_OPT  = -L $(UVM_LIB_NAME) +incdir+$(UVM_HOME)/src
UVM_VSIM_OPT  = -L $(UVM_LIB_NAME)
else
UVM_VLOG_OPT  =
UVM_VSIM_OPT  =
endif

# ====================================================================================
# CÁC TARGET CHÍNH
# ====================================================================================
.PHONY: all all_wave all_cov init build build_cov run run_cov wave gen_cov gen_html clean help

all: build run
all_wave: build run wave
all_cov: build_cov run_cov gen_all_reports
# ====================================================================================
# KHỞI TẠO CÂY THƯ MỤC VÀ TỰ ĐỘNG GOM FILE (MAKE INIT)
# ====================================================================================
init:
	@echo "============================================================"
	@echo " [INIT] Bắt đầu tự động sắp xếp thư mục và dọn dẹp dự án..."
	@echo "============================================================"
	@mkdir -p $(RTL_DIR)
	@mkdir -p $(TB_DIR)/agents/ahb_agent
	@mkdir -p $(TB_DIR)/agents/apb_agent
	@mkdir -p $(TB_DIR)/env
	@mkdir -p $(TB_DIR)/assertions
	@mkdir -p $(TB_DIR)/tests
	@mkdir -p $(DOCS_DIR)
	@mkdir -p $(SIM_DIR)/log

	@echo "-> Đang phân loại các file vào thư mục tương ứng..."
	@bash -c ' \
		# 1. Di chuyển tài liệu \
		mv $(PROJ_ROOT)/*.xlsx $(DOCS_DIR)/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/*.pdf $(DOCS_DIR)/ 2>/dev/null || true; \
		\
		# 2. Di chuyển RTL \
		mv $(PROJ_ROOT)/Bridge_top_.v $(RTL_DIR)/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/AHB_Slave_Interface_.v $(RTL_DIR)/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/APB_Controller_.v $(RTL_DIR)/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/design.sv $(RTL_DIR)/ 2>/dev/null || true; \
		\
		# 3. Di chuyển SVA \
		mv $(PROJ_ROOT)/ahb2apb_bridge_props.sv $(TB_DIR)/assertions/ 2>/dev/null || true; \
		\
		# 4. Di chuyển AHB Agent \
		mv $(PROJ_ROOT)/ahb_*.sv $(TB_DIR)/agents/ahb_agent/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/ahb_*.svh $(TB_DIR)/agents/ahb_agent/ 2>/dev/null || true; \
		\
		# 5. Di chuyển APB Agent \
		mv $(PROJ_ROOT)/apb_*.sv $(TB_DIR)/agents/apb_agent/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/apb_*.svh $(TB_DIR)/agents/apb_agent/ 2>/dev/null || true; \
		\
		# 6. Di chuyển Environment & Scoreboard \
		mv $(PROJ_ROOT)/environment.sv $(TB_DIR)/env/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/scoreboard.sv $(TB_DIR)/env/ 2>/dev/null || true; \
		\
		# 7. Di chuyển Tests \
		mv $(PROJ_ROOT)/*test*.sv $(TB_DIR)/tests/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/test_files.svh $(TB_DIR)/tests/ 2>/dev/null || true; \
		mv $(PROJ_ROOT)/burst_seq_w_busy_*.sv $(TB_DIR)/tests/ 2>/dev/null || true; \
		\
		# 8. Di chuyển Top testbench (nếu là testbench.sv thì chuyển thành top.sv) \
		if [ -f "$(PROJ_ROOT)/testbench.sv" ]; then \
			mv $(PROJ_ROOT)/testbench.sv $(TB_DIR)/top.sv; \
		fi; \
		\
		# 9. Dọn các file rác phát sinh cũ \
		rm -rf $(PROJ_ROOT)/csrc $(PROJ_ROOT)/simv* $(PROJ_ROOT)/*.vcd $(PROJ_ROOT)/ucli.key $(PROJ_ROOT)/*.setup $(PROJ_ROOT)/run.sh 2>/dev/null || true; \
	'

	@echo "-> Đang tạo compile.f..."
	@( \
		echo "// ==========================================================="; \
		echo "// COMPILE.F - AHB2APB BRIDGE VERIFICATION"; \
		echo "// ==========================================================="; \
		echo "// --- RTL Source ---"; \
		echo "$(RTL_DIR)/Bridge_top_.v"; \
		echo "$(RTL_DIR)/AHB_Slave_Interface_.v"; \
		echo "$(RTL_DIR)/APB_Controller_.v"; \
		echo ""; \
		echo "// --- Top Testbench ---"; \
		echo "$(TB_DIR)/top.sv"; \
	) > $(COMPILE_FILE)

	@echo "============================================================"
	@echo " [INIT THÀNH CÔNG] Toàn bộ file đã được gom ngăn nắp!"
	@echo " File list được tạo tại: $(COMPILE_FILE)"
	@echo "============================================================"

# ====================================================================================
# BIÊN DỊCH (BUILD)
# ====================================================================================
build:
	@mkdir -p $(SIM_DIR)/log
	@echo "============================================================"
	@echo " [BUILD] Biên dịch dự án"
	@echo " Test đang chọn: $(TEST)"
	@echo " Top module    : $(TB_MODULE)"
	@echo "============================================================"
	rm -rf $(SIM_DIR)/work
	cd $(SIM_DIR) && vlib work
	cd $(SIM_DIR) && vmap work work
ifeq ($(USE_UVM), 1)
	cd $(SIM_DIR) && vmap $(UVM_LIB_NAME) $(UVM_LIB)
endif
	cd $(SIM_DIR) && \
	set -o pipefail; \
	vlog -sv \
		$(UVM_VLOG_OPT) \
		$(INCDIRS) \
		$(DEFINES) \
		-f $(COMPILE_FILE) \
		2>&1 | tee log/compile.log
	@echo "Biên dịch thành công! Log: $(SIM_DIR)/log/compile.log"

# ====================================================================================
# BIÊN DỊCH VỚI COVERAGE
# ====================================================================================
build_cov:
	@mkdir -p $(SIM_DIR)/log
	@echo "============================================================"
	@echo " [BUILD COVERAGE] Bật Code Coverage & Functional Coverage"
	@echo "============================================================"
	rm -rf $(SIM_DIR)/work
	cd $(SIM_DIR) && vlib work
	cd $(SIM_DIR) && vmap work work
ifeq ($(USE_UVM), 1)
	cd $(SIM_DIR) && vmap $(UVM_LIB_NAME) $(UVM_LIB)
endif
	cd $(SIM_DIR) && \
	set -o pipefail; \
	vlog -sv \
		+cover=bcesft \
		$(UVM_VLOG_OPT) \
		$(INCDIRS) \
		$(DEFINES) \
		-f $(COMPILE_FILE) \
		2>&1 | tee log/compile_cov.log

# ====================================================================================
# CHẠY MÔ PHỎNG (RUN)
# ====================================================================================
run:
	@echo "============================================================"
	@echo " [RUN] Đang chạy mô phỏng: $(TEST)"
	@echo "============================================================"
	cd $(SIM_DIR) && \
	vsim \
		$(UVM_VSIM_OPT) \
		-c $(TB_MODULE) \
		-voptargs="+acc" \
		-assertdebug \
		-l sim_$(TEST).log \
		-do "log -r /*; run -all; quit -f"
	@echo "Mô phỏng hoàn tất! Log lưu tại: $(SIM_DIR)/sim_$(TEST).log"

# ====================================================================================
# CHẠY MÔ PHỎNG LƯU COVERAGE DATABASE (.UCDB)
# ====================================================================================
run_cov:
	@echo "============================================================"
	@echo " [RUN COVERAGE] Chạy và lưu cơ sở dữ liệu coverage..."
	@echo "============================================================"
	cd $(SIM_DIR) && \
	vsim \
		$(UVM_VSIM_OPT) \
		-c $(TB_MODULE) \
		-coverage \
		-voptargs="+cover=bcesft" \
		-assertdebug \
		-l sim_cov_$(TEST).log \
		-do "coverage save -onexit $(TEST).ucdb; log -r /*; run -all; quit -f"

# ====================================================================================
# XEM DẠNG SÓNG (WAVEFORM)
# ====================================================================================
wave:
	@echo "============================================================"
	@echo " [WAVE] Mở dạng sóng waveform..."
	@echo "============================================================"
	cd $(SIM_DIR) && \
	vsim -i -view vsim.wlf -do "add wave -r /*; radix -$(RADIX)" &

# ====================================================================================
# XUẤT BÁO CÁO COVERAGE (TEXT & HTML)
# ====================================================================================
gen_all_reports:
	@mkdir -p $(SIM_DIR)/coverage_report
	@mkdir -p $(SIM_DIR)/coverage_html
	cd $(SIM_DIR) && \
	vsim -c -viewcov $(TEST).ucdb -do "do exclude.do; coverage save $(TEST).ucdb; quit -f" && \
	vcover report -summary -showexcluded $(TEST).ucdb -output coverage_report/summary.txt && \
	vcover report -details -code bcesft -annotate -all -showexcluded $(TEST).ucdb -output coverage_report/details.txt && \
	vcover report -html -details -code bcesft -annotate -testhitdataAll -showexcluded $(TEST).ucdb -output coverage_html
	@echo "=== Đã cập nhật xong toàn bộ báo cáo ==="
# ====================================================================================
# DỌN DẸP (CLEAN)
# ====================================================================================
clean:
	rm -rf $(SIM_DIR) transcript vsim.wlf *.log *.ucdb
	@echo "Đã dọn dẹp sạch sẽ thư mục mô phỏng."

# ====================================================================================
# HƯỚNG DẪN DÙNG (HELP)
# ====================================================================================
help:
	@echo ""
	@echo "************************************************************************"
	@echo "** HƯỚNG DẪN SỬ DỤNG MAKEFILE CHO AHB2APB BRIDGE VERIFICATION         **"
	@echo "************************************************************************"
	@echo "**"
	@echo "** 1. make init            : Tự động gom file vào các thư mục chuẩn VSCode"
	@echo "** 2. make build           : Biên dịch RTL và Testbench"
	@echo "** 3. make run             : Chạy mô phỏng test mặc định (normal_burst_seq_test)"
	@echo "** 4. make run TEST=<tên>  : Chạy test chỉ định (vd: make run TEST=mixed_seq_test)"
	@echo "** 5. make all             : Biên dịch và chạy mô phỏng"
	@echo "** 6. make all_cov         : Chạy với coverage và xuất báo cáo text"
	@echo "** 7. make gen_html        : Xuất báo cáo coverage giao diện trực quan HTML"
	@echo "** 8. make wave            : Mở trình xem sóng waveform"
	@echo "** 9. make clean           : Xóa toàn bộ file build và log"
	@echo "************************************************************************"
	@echo ""