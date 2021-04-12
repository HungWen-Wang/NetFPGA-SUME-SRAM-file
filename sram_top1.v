`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/31/2021 11:51:08 AM
// Design Name: 
// Module Name: sram_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sram_top1
	(
		//reference_router port 
	    input   [29:0]          user_addr                ,     
	    input   [2:0]           user_cmd                 ,
	    input                   user_en                  ,
	    input   [512:0]         user_wdf_data            ,
	    input   [63:0]          user_wdf_mask            , 
	    
	    output  reg  [512:0]         user_rd_data             ,
	    output  reg                  user_rd_data_end         ,
	    output  reg                  user_rd_data_valid       ,
	    
	    output                  user_rdy                 ,
	    output                  user_wdf_rdy             ,

	    input                   user_wdf_end             ,
	    input                   user_wdf_wren            ,

	   // Inouts
	   inout [63:0]                         ddr3_dq,
	   inout [7:0]                          ddr3_dqs_n,
	   inout [7:0]                          ddr3_dqs_p,
	   // Outputs
	   output [15:0]                        ddr3_addr,
	   output [2:0]                         ddr3_ba,
	   output                               ddr3_ras_n,
	   output                               ddr3_cas_n,
	   output                               ddr3_we_n,
	   output                               ddr3_reset_n,
	   output [0:0]                        	ddr3_ck_p,
	   output [0:0]                        	ddr3_ck_n,
	   output [0:0]                       	ddr3_cke,
	   output [0:0]           				ddr3_cs_n,
	   output [7:0]                        	ddr3_dm,
	   output [0:0]                       	ddr3_odt,
	   // Inputs
	   // Differential system clocks
	   input                                        sys_clk_p,
	   input                                        sys_clk_n,
	   // input                                        sys_clk_i,
	   // differential iodelayctrl clk (reference clock)
	   // input                                        clk_ref_p,
	   // input                                        clk_ref_n,
	   // input                                        clk_ref_i,

	   output                                       tg_compare_error,
	   output                                       init_calib_complete,
	   
	      

	   // System reset - Default polarity of sys_rst pin is Active Low.
	   // System reset polarity will change based on the option 
	   // selected in GUI.
	   input                                        sys_rst
    );

  reg [29:0]                 			app_addr;
  reg [2:0]                            	app_cmd;
  reg                                  	app_en;
  wire                                  app_rdy;
  wire [512:0]             				app_rd_data;
  wire                                  app_rd_data_end;
  wire                                  app_rd_data_valid;
  reg [512:0]             				app_wdf_data;
  reg                                  	app_wdf_end;
  reg [63:0]             				app_wdf_mask;
  wire                                  app_wdf_rdy;
  reg                                  	app_wdf_wren;

  wire                                  app_sr_active;
  wire                                  app_ref_ack;
  wire                                  app_zq_ack;
  

  wire                                  clk;
  wire                                  rst;
     
	wire [11:0]                          device_temp;

	`ifdef SKIP_CALIB
	  // skip calibration wires
	  wire                          calib_tap_req;
	  reg                           calib_tap_load;
	  reg [6:0]                     calib_tap_addr;
	  reg [7:0]                     calib_tap_val;
	  reg                           calib_tap_load_done;
	`endif


	// Start of User Design top instance
//***************************************************************************
// The User design is instantiated below. The memory interface ports are
// connected to the top-level and the application interface ports are
// connected to the traffic generator module. This provides a reference
// for connecting the memory controller to system.
//***************************************************************************
	
	always @(posedge clk) begin
            app_addr = user_addr;
            app_cmd = user_cmd;
            app_wdf_mask = 64'b0;
            app_en = user_en;
            case(user_cmd)
                3'b000:
                    if (app_rdy && app_wdf_rdy) begin
                        app_wdf_wren = user_wdf_wren;
                        app_wdf_end = user_wdf_end;
                        app_wdf_data = user_wdf_data;
                    end
                3'b001:
                    if (app_rdy && app_rd_data_end && app_rd_data_valid) begin
                        user_rd_data = app_rd_data;
                    end
                    else begin
                        user_rd_data = 0;
                    end
                default:
                    begin
                        user_rd_data = 0;
                    end
            endcase
        end

 	
	mig_7a_0 u_mig_7a_0
    (   
// Memory interface ports
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (init_calib_complete),
      
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
// Application interface ports
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_end                (app_rd_data_end),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),
       .ui_clk                         (clk),
       .ui_clk_sync_rst                (rst),
      
       .app_wdf_mask                   (app_wdf_mask),
      
       
// // System Clock Ports
       .sys_clk_p                       (sys_clk_p),
       .sys_clk_n                       (sys_clk_n),
// // Reference Clock Ports
//        .clk_ref_p                      (clk_ref_p),
//        .clk_ref_n                      (clk_ref_n),
//        .device_temp            (device_temp),
//        `ifdef SKIP_CALIB
//        .calib_tap_req                    (calib_tap_req),
//        .calib_tap_load                   (calib_tap_load),
//        .calib_tap_addr                   (calib_tap_addr),
//        .calib_tap_val                    (calib_tap_val),
//        .calib_tap_load_done              (calib_tap_load_done),
//        `endif
      
//        .sys_rst                        (sys_rst)
		// System Clock Ports
       // .sys_clk_i                       (sys_clk_i),
		// Reference Clock Ports
       // .clk_ref_i                      (clk_ref_i),
       .device_temp            (device_temp),
       `ifdef SKIP_CALIB
       .calib_tap_req                    (calib_tap_req),
       .calib_tap_load                   (calib_tap_load),
       .calib_tap_addr                   (calib_tap_addr),
       .calib_tap_val                    (calib_tap_val),
       .calib_tap_load_done              (calib_tap_load_done),
       `endif
      
       .sys_rst                        (sys_rst)
       );
// End of User Design top instance
endmodule
