# ==============================================================================
# Complete Exclusion Script for 100% Coverage Closure
# ==============================================================================

# 1. Loai tru Testbench va Assertion Wrapper khoi Code Coverage
catch {coverage exclude -du work.top_sv_unit}
catch {coverage exclude -scope /top_sv_unit}
catch {coverage exclude -scope /top}
catch {coverage exclude -scope /top/DUT/ahb2apb_bridge_props_inst}

# 2. Loai tru Toggle tren Interface in0 va in1
catch {coverage exclude -toggle {/top/in0/Haddr[1:0]}}
catch {coverage exclude -toggle {/top/in0/Haddr[30:28]}}
catch {coverage exclude -toggle /top/in0/Haddr(31)}
catch {coverage exclude -toggle /top/in0/Hburst(0)}
catch {coverage exclude -toggle /top/in0/Hburst(1)}
catch {coverage exclude -toggle /top/in0/Hburst(2)}
catch {coverage exclude -toggle /top/in0/Hreadyin}
catch {coverage exclude -toggle /top/in0/Hresetn}
catch {coverage exclude -toggle /top/in0/Hresp}

catch {coverage exclude -toggle {/top/in1/Paddr[1:0]}}
catch {coverage exclude -toggle {/top/in1/Paddr[30:28]}}
catch {coverage exclude -toggle /top/in1/Paddr(31)}

# 3. Loai tru Toggle tren Bridge_Top (/top/DUT)
catch {coverage exclude -toggle {/top/DUT/Haddr[1:0]}}
catch {coverage exclude -toggle {/top/DUT/Paddr[1:0]}}
catch {coverage exclude -toggle {/top/DUT/Haddr[30:28]}}
catch {coverage exclude -toggle {/top/DUT/Paddr[30:28]}}
catch {coverage exclude -toggle /top/DUT/Haddr(31)}
catch {coverage exclude -toggle /top/DUT/Paddr(31)}
catch {coverage exclude -toggle /top/DUT/Haddr1(0)}
catch {coverage exclude -toggle /top/DUT/Haddr1(1)}
catch {coverage exclude -toggle /top/DUT/Haddr1(28)}
catch {coverage exclude -toggle /top/DUT/Haddr1(29)}
catch {coverage exclude -toggle /top/DUT/Haddr1(30)}
catch {coverage exclude -toggle /top/DUT/Haddr1(31)}
catch {coverage exclude -toggle /top/DUT/Haddr2(0)}
catch {coverage exclude -toggle /top/DUT/Haddr2(1)}
catch {coverage exclude -toggle /top/DUT/Haddr2(28)}
catch {coverage exclude -toggle /top/DUT/Haddr2(29)}
catch {coverage exclude -toggle /top/DUT/Haddr2(30)}
catch {coverage exclude -toggle /top/DUT/Haddr2(31)}
catch {coverage exclude -toggle /top/DUT/Hreadyin}
catch {coverage exclude -toggle /top/DUT/Hresetn}
catch {coverage exclude -toggle /top/DUT/Hresp}
catch {coverage exclude -toggle {/top/DUT/addr_outstanding_num[1]}}

# 4. Loai tru Toggle tren AHBSlave (/top/DUT/AHBSlave)
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(0)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(1)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(28)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(29)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(30)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr1(31)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(0)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(1)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(28)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(29)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(30)}
catch {coverage exclude -toggle /top/DUT/AHBSlave/Haddr2(31)}
catch {coverage exclude -toggle {/top/DUT/AHBSlave/addr_outstanding_num[1]}}

# 5. Loai tru Toggle, Branch, Condition va FSM tren APBControl (/top/DUT/APBControl)
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(0)}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(1)}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(28)}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(29)}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(30)}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr(31)}
catch {coverage exclude -toggle {/top/DUT/APBControl/Paddr_temp[1:0]}}
catch {coverage exclude -toggle {/top/DUT/APBControl/Paddr_temp[30:28]}}
catch {coverage exclude -toggle /top/DUT/APBControl/Paddr_temp(31)}

catch {coverage exclude -scope /top/DUT/APBControl -ftrans PRESENT_STATE ST_READ->ST_IDLE ST_WWAIT->ST_IDLE ST_WRITEP->ST_IDLE ST_WRITE->ST_IDLE ST_WENABLEP->ST_IDLE}
catch {coverage exclude -du work.APB_FSM_Controller -ftrans PRESENT_STATE ST_READ->ST_IDLE ST_WWAIT->ST_IDLE ST_WRITEP->ST_IDLE ST_WRITE->ST_IDLE ST_WENABLEP->ST_IDLE}
catch {coverage exclude -scope /top/DUT/APBControl -line 246 -code bc}
catch {coverage exclude -scope /top/DUT/APBControl -line 255 -code bc}
catch {coverage exclude -scope /top/DUT/APBControl -line 272-293 -code sbc}
catch {coverage exclude -scope /top/DUT/APBControl -line 58 89 98 131 133 135 153 225 -code c}