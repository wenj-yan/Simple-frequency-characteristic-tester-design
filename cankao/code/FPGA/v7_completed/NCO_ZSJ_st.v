//	Copyright (C) 1988-2012 Altera Corporation

//	Any megafunction design, and related net list (encrypted or decrypted),
//	support information, device programming or simulation file, and any other
//	associated documentation or information provided by Altera or a partner
//	under Altera's Megafunction Partnership Program may be used only to
//	program PLD devices (but not masked PLD devices) from Altera.  Any other
//	use of such megafunction design, net list, support information, device
//	programming or simulation file, or any other related documentation or
//	information is prohibited for any other purpose, including, but not
//	limited to modification, reverse engineering, de-compiling, or use with
//	any other silicon devices, unless such use is explicitly licensed under
//	a separate agreement with Altera or a megafunction partner.  Title to
//	the intellectual property, including patents, copyrights, trademarks,
//	trade secrets, or maskworks, embodied in any such megafunction design,
//	net list, support information, device programming or simulation file, or
//	any other related documentation or information provided by Altera or a
//	megafunction partner, remains with Altera, the megafunction partner, or
//	their respective licensors.  No other licenses, including any licenses
//	needed under any third party's intellectual property, are provided herein.


module NCO_ZSJ_st(clk, reset_n, clken, phi_inc_i, fsin_o, fcos_o, out_valid);

parameter mpr = 32;
parameter opr = 64;
parameter oprp1 = 65;
parameter apr = 16;
parameter apri= 16;
parameter aprf= 32;
parameter aprp= 16;
parameter aprid=21;
parameter dpri= 5;
parameter rdw = 32;
parameter rawc = 8;
parameter rnwc = 256;
parameter rawf = 8;
parameter rnwf = 256;
parameter Pn = 16384;
parameter mxnbc = 8192;
parameter mxnbf = 8192;
parameter rsfc = "NCO_ZSJ_sin_c.hex";
parameter rsff = "NCO_ZSJ_sin_f.hex";
parameter rcfc = "NCO_ZSJ_cos_c.hex";
parameter rcff = "NCO_ZSJ_cos_f.hex";
parameter nc = 1;
parameter pl = nc;
parameter log2nc =0;
parameter outselinit = -1;
parameter paci0= 0;
parameter paci1= 0;
parameter paci2= 0;
parameter paci3= 0;
parameter paci4= 0;
parameter paci5= 0;
parameter paci6= 0;
parameter paci7= 0;

input clk; 
input reset_n; 
input clken; 
input [apr-1:0] phi_inc_i; 

output [mpr-1:0] fsin_o;
output [mpr-1:0] fcos_o;
output out_valid;
wire reset; 
assign reset = !reset_n;

wire [apr-1:0]  phi_inc_i_w;
wire [apr-1:0] phi_acc_w;
wire [mpr-1:0] rfx_s;	
wire [mpr-1:0] rcx_s;
wire [mpr-1:0] rfx_c;	
wire [mpr-1:0] rcx_c;
wire [mpr-1:0] rfy_s;	
wire [mpr-1:0] rcy_s;
wire [mpr-1:0] rfy_c;	
wire [mpr-1:0] rcy_c;
wire [rawc-1:0] raxxx001ms; 
wire [rawc-1:0] raxxx001mc; 
wire [rawc-1:0] raxxx000m; 
wire [rawf-1:0] raxxx000l; 
wire [rawc-1:0] raxxx001m; 
wire [rawf-1:0] raxxx001l; 
wire [aprid-1:0] phi_acc_w_d;
wire [aprid-1:0] phi_acc_w_di;
wire [dpri-1:0] rval_w_d;
wire [dpri-1:0] rval_w;
wire select_s;
wire select_c;
wire [opr:0] result_i;	
wire [opr:0] result_r;	
wire [mpr-1:0] fsin_o_w;	
wire [mpr-1:0] fcos_o_w;	

assign phi_inc_i_w = phi_inc_i;




asj_altqmcpipe ux000 (.clk(clk), 
             .reset(reset), 
             .clken(clken), 
             .phi_inc_int(phi_inc_i_w), 
             .phi_acc_reg(phi_acc_w)
             );

defparam ux000.apr = apr ;
defparam ux000.lat = 1 ;
defparam ux000.nc = pl ;
defparam ux000.paci0 = paci0 ;
defparam ux000.paci1 = paci1 ;
defparam ux000.paci2 = paci2 ;
defparam ux000.paci3 = paci3 ;
defparam ux000.paci4 = paci4 ;
defparam ux000.paci5 = paci5 ;
defparam ux000.paci6 = paci6 ;
defparam ux000.paci7 = paci7 ;

asj_dxx_g ux001(.clk(clk), 
            .clken(clken), 
              .reset(reset), 
              .dxxrv(rval_w_d)
              );
defparam ux001.dpri = dpri;
assign rval_w = rval_w_d;
asj_dxx ux002(.clk(clk), 
            .clken(clken), 
	         .reset(reset), 
            .dxxpdi(phi_acc_w_di), 
            .rval(rval_w), 
            .dxxpdo(phi_acc_w_d) 
           );

defparam ux002.aprid = aprid;
defparam ux002.dpri = dpri;

asj_nco_aprid_dxx ux0219(.pcc_w(phi_acc_w),
                         .pcc_d(phi_acc_w_di)
                         ); 
defparam ux0219.apr = apr;    
defparam ux0219.aprid = aprid;


asj_gam_dp ux008( .clk(clk),
                   .reset(reset), 
                   .clken(clken), 
                   .phi_acc_w(phi_acc_w_d[aprid-1:aprid-rawc-rawf]),
                   .rom_add_cs(raxxx001ms),
                   .rom_add_cc(raxxx001mc),
                   .rom_add_f(raxxx001l)
                   );
defparam ux008.rawc = rawc;
defparam ux008.rawf = rawf;
defparam ux008.apr = apri;


asj_nco_as_m_dp_cen ux0220(.clk(clk),
                   .clken (clken),
                   .raxx_a(raxxx001ms[rawc-1:0]),
                   .raxx_b(raxxx001mc[rawc-1:0]),
                   .q_a(rcx_s[mpr-1:0]),
                   .q_b(rcx_c[mpr-1:0])
                     );
defparam ux0220.mpr = mpr;
defparam ux0220.rdw = rdw;
defparam ux0220.raw = rawc;
defparam ux0220.rnw = rnwc;
defparam ux0220.rf = rsfc;
defparam ux0220.dev = "CycloneII";

asj_nco_as_m_cen ux0122(.clk(clk),
                   .clken (clken),
                   .raxx(raxxx001l[rawf-1:0]),
                   .srw_int_res(rfx_s[mpr-1:0])
                     );
defparam ux0122.mpr = mpr;
defparam ux0122.rdw = rdw;
defparam ux0122.raw = rawf;
defparam ux0122.rnw = rnwf;
defparam ux0122.rf = rsff;
defparam ux0122.dev = "CycloneII";

asj_nco_as_m_cen ux0123(.clk(clk),
                   .clken (clken),
                   .raxx(raxxx001l[rawf-1:0]),
                   .srw_int_res(rfx_c[mpr-1:0])
                     );
defparam ux0123.mpr = mpr;
defparam ux0123.rdw = rdw;
defparam ux0123.raw = rawf;
defparam ux0123.rnw = rnwf;
defparam ux0123.rf = rcff;
defparam ux0123.dev = "CycloneII";

mac_i_lpmd m0(.clk(clk),
         .reset(reset), 
         .clken(clken), 
         .a_or_s(select_c),
         .dataa_0(rcy_s),
         .dataa_1(rfy_s),
         .datab_0(rfy_c),
         .datab_1(rcy_c),
         .result(result_i));
defparam m0.mpr = mpr;
defparam m0.opr = opr;
defparam m0.oprp1 = oprp1;

mac_i_lpmd m1(.clk(clk),
         .reset(reset), 
         .clken(clken), 
         .a_or_s(select_s),
         .dataa_0(rcy_c),
         .dataa_1(rcy_s),
         .datab_0(rfy_c),
         .datab_1(rfy_s),
         .result(result_r));
defparam m1.mpr = mpr;
defparam m1.opr = opr;
defparam m1.oprp1 = oprp1;

asj_nco_derot ux0136(.crwx_rc(rcx_c),
                     .crwx_rf(rfx_c),
                     .srwx_rc(rcx_s),
                     .srwx_rf(rfx_s),
                     .crwy_rc(rcy_c),
                     .crwy_rf(rfy_c),
                     .srwy_rc(rcy_s),
                     .srwy_rf(rfy_s)
                     );
defparam ux0136.mpr = mpr;
defparam ux0136.rxt = rdw;

assign select_s = 1'b0; 
asj_nco_mob_w blk0( .clk(clk),
                    .reset(reset),
                    .clken(clken),
                    .data_in(result_i),
                    .data_out(fsin_o_w));

defparam blk0.mpr = mpr;
defparam blk0.opr = opr;
assign select_c = 1'b1; 
asj_nco_mob_w blk1( .clk(clk),
                    .reset(reset),
                    .clken(clken),
                    .data_in(result_r),
                    .data_out(fcos_o_w));

defparam blk1.mpr = mpr;
defparam blk1.opr = opr;
assign fsin_o = fsin_o_w;
assign fcos_o = fcos_o_w;


asj_nco_isdr ux710isdr(.clk(clk),                              
                    .reset(reset),                          
                    .clken(clken),                  
                    .data_ready(out_valid)          
                    );                                      
defparam ux710isdr.ctc=12;                                       
defparam ux710isdr.cpr=4;                                   
                                                            

endmodule