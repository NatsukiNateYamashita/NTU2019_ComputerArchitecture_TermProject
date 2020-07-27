module dcache_top
(
    // System clock, reset and stall
    clk_i,
    rst_i,

    // to Data Memory interface
    mem_data_i,
    mem_ack_i,
    mem_data_o,
    mem_addr_o,
    mem_enable_o,
    mem_write_o,

    // to CPU interface
    p1_data_i,
    p1_addr_i,
    p1_MemRead_i,
    p1_MemWrite_i,
    p1_data_o,
    p1_stall_o
);
//
// System clock, start
//
input                 clk_i;
input                 rst_i;

//
// to Data Memory interface
//
input    [256-1:0]    mem_data_i;
input                 mem_ack_i;

output   [256-1:0]    mem_data_o;
output   [32-1:0]     mem_addr_o;
output                mem_enable_o;
output                mem_write_o;

//
// to core interface
//
input    [32-1:0]     p1_data_i;
input    [32-1:0]     p1_addr_i;
input                 p1_MemRead_i;
input                 p1_MemWrite_i;

output   [32-1:0]     p1_data_o;
output                p1_stall_o;

//
// to SRAM interface
//
wire    [4:0]         cache_sram_index;
wire                  cache_sram_enable;
wire    [23:0]        cache_sram_tag;
wire    [255:0]       cache_sram_data;
wire                  cache_sram_write;
wire    [23:0]        sram_cache_tag;
wire    [255:0]       sram_cache_data;


// cache
wire                  sram_valid;
wire                  sram_dirty;

// controller
parameter             STATE_IDLE         = 3'h0,
                      STATE_READMISS     = 3'h1,
                      STATE_READMISSOK   = 3'h2,
                      STATE_WRITEBACK    = 3'h3,
                      STATE_MISS         = 3'h4;
reg     [2:0]         state;
reg                   mem_enable;
reg                   mem_write;
reg                   cache_we; // write enable to cache
wire                  cache_dirty;
reg                   write_back;

// regs & wires
wire    [4:0]         p1_offset;
wire    [4:0]         p1_index;
wire    [21:0]        p1_tag;
wire    [255:0]       r_hit_data;
wire    [21:0]        sram_tag;
wire                  hit;            //YAMASHITA: p23
reg     [255:0]       w_hit_data;
wire                  write_hit;
wire                  p1_req;
reg     [31:0]        p1_data;

// project1 interface
assign    p1_req     = p1_MemRead_i | p1_MemWrite_i;
assign    p1_offset  = p1_addr_i[4:0];
assign    p1_index   = p1_addr_i[9:5];
assign    p1_tag     = p1_addr_i[31:10];
assign    p1_stall_o = ~hit & p1_req;     //YAMASHITA: if this condition is satisfied, the state become STATE_MISS in line178, SO NEED TO STALL. In STATE_READMISSOK, the data in the cache will have been updated, then hit will be 1 and state will be STATE_IDLE, so will stop to stall.
assign    p1_data_o  = p1_data;

// SRAM interface
assign    sram_valid = sram_cache_tag[23];
assign    sram_dirty = sram_cache_tag[22];
assign    sram_tag   = sram_cache_tag[21:0];
assign    cache_sram_index  = p1_index;
assign    cache_sram_enable = p1_req;
assign    cache_sram_write  = cache_we | write_hit;
assign    cache_sram_tag    = {1'b1, cache_dirty, p1_tag};
assign    cache_sram_data   = (hit) ? w_hit_data : mem_data_i;

// memory interface
assign    mem_enable_o = mem_enable;
assign    mem_addr_o   = (write_back) ? {sram_tag, p1_index, 5'b0} : {p1_tag, p1_index, 5'b0}; //YAMASHITA: if dirty, write data in cache to memory. if not dirty(=do not need to write back), read data from memory or write data in cache directly
assign    mem_data_o   = sram_cache_data;
assign    mem_write_o  = mem_write;

assign    write_hit    = hit & p1_MemWrite_i;
assign    cache_dirty  = write_hit;

integer index;

// tag comparator
// TODO: add you code here!  (hit=...?,  r_hit_data=...?)
  //YAMASHITA
  //at first, check whether valid or NOT
  //secondly, check whether tag is same or NOT
assign hit = (sram_valid && sram_tag == p1_tag )? 1'b1 :
                                                  1'b0 ;
  //if hit, read from cache
  //if not, read from memory
  //wire    [255:0]       r_hit_data;
  //wire    [255:0]       sram_cache_data;
  //input    [256-1:0]    mem_data_i;
assign r_hit_data = (hit)? sram_cache_data: //YAMASHITA: from dcache_data_sram.data_o(sram_cache_data)
                           mem_data_i;      //YAMASHITA: Data_Memory->testbench.Data_Memory->testbench.CPU->CPU.dcache_top

// read data :  256-bit to 32-bit
always@(p1_offset or r_hit_data) begin
    // TODO: add you code here! (p1_data=...?)
      //YAMASHITA
      //data from cache to CPU
      //reg     [31:0]      p1_data;    to p1_data_o(address of data in cache)
      //wire  	[4:0]		    p1_offset;
      //assign    p1_offset  = p1_addr_i[4:0];
      //wire    [255:0]     r_hit_data;
      //YAMASHITA:  offset*c indicates the place in 'r_hit_data' and extract the continuous 32bits data.
    //p1_data = r_hit_data[p1_offset*8+31:p1_offset*8];
		index <= p1_offset*8;
		p1_data = r_hit_data[index+:32];
end

// write data :  32-bit to 256-bit
always@(p1_offset or r_hit_data or p1_data_i) begin
    // TODO: add you code here! (w_hit_data=...?)
      //reg     [255:0]       w_hit_data;
      //assign    cache_sram_data = (hit) ? w_hit_data : mem_data_i;
      //dcache_data_sram.data_i(cache_sram_data)

      //when read miss, write data in cache from memory
      w_hit_data <= r_hit_data;

      //when write, write data in cache from CPU
      //w_hit_data[p1_offset*8+31:p1_offset*8] <= p1_data_i;
	  index <= p1_offset*8;
	  w_hit_data[index+:32] <= p1_data_i;
end

// controller
// reference: the 64 page of ppt"Memory-Hiearchy"
always@(posedge clk_i or negedge rst_i) begin
    if(~rst_i) begin
        state      <= STATE_IDLE;
        mem_enable <= 1'b0;
        mem_write  <= 1'b0;
        cache_we   <= 1'b0;
        write_back <= 1'b0;
    end
    else begin
        case(state)
            STATE_IDLE: begin
                //p1_req     = p1_MemRead_i | p1_MemWrite_i;
                if(p1_req && !hit) begin      //wait for request
                    state <= STATE_MISS;
                end
                else begin
                    state <= STATE_IDLE;
                end
            end
            STATE_MISS: begin
                //assign    sram_dirty = sram_cache_tag[22];
                //assign    cache_sram_tag    = {1'b1, cache_dirty, p1_tag};
                //assign    cache_dirty  = write_hit;
                //assign    write_hit    = hit & p1_MemWrite_i;
                //YAMASHITA: write data in memory
                if(sram_dirty) begin          //write back if dirty
                    // TODO: add you code here!
                    mem_enable <= 1'b1; //YAMASHITA:  access memory
                    mem_write  <= 1'b1; //YAMASHITA:  write data in memory
                    cache_we   <= 1'b0; //YAMASHITA:  This state deals with only memory(reference the 64 page of ppt"Memory-Hiearchy")
                    write_back <= 1'b1; //YAMASHITA:  write data in memory because of dirty
                    state <= STATE_WRITEBACK;
                end
                else begin                      //write allocate: write miss = read miss + write hit; read miss = read miss + read hit
                    // TODO: add you code here! //YAMASHITA: if not hit,because of "read miss = read miss + read hit"
                    mem_enable <= 1'b1; //YAMASHITA:  access memory
                    mem_write  <= 1'b0; //YAMASHITA:  do not write data in memory because data is not dirty
                    cache_we   <= 1'b0; //YAMASHITA:  This state deals with only memory()
                    write_back <= 1'b0; //YAMASHITA:  do not write data in memory because focus on reading data in this state(reference the 64 page of ppt"Memory-Hiearchy")
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISS: begin
                //IN Data_Memory: assign    ack_o = (state == STATE_WAIT) && (count == 4'd9);
                //YAMASHITA: This means data is ready in memory, so data should be written into the cache
                if(mem_ack_i) begin            //wait for data memory acknowledge
                    // TODO: add you code here!
                    mem_enable <= 1'b0; //YAMASHITA: need to set 0, because this signal was set as 1 in STATE_MISS(when write allocate) and has been used for accessing memory until reading data in memory
                    //mem_write  <= 1'b0; //YAMASHITA: This state deals with only cache
                    cache_we   <= 1'b1; //YAMASHITA: write data in cache because data is ready in memory
                    //write_back <= 1'b0; //YAMASHITA: This state deals with only cache
                    state <= STATE_READMISSOK;
                end
                //YAMASHITA: wait for data memory acknowledge
                else begin
                    state <= STATE_READMISS;
                end
            end
            STATE_READMISSOK: begin            //wait for data memory acknowledge
                // TODO: add you code here!
                cache_we <= 1'b0; //YAMASHITA:  need to set 0, because this signal was set as 1 in the last of STATE_READMISS(already written ready-data into cache)
                state <= STATE_IDLE;
            end
            STATE_WRITEBACK: begin
                //IN Data_Memory: assign    ack_o = (state == STATE_WAIT) && (count == 4'd9);
                //YAMASHITA: This means data is ready in memory, so data should be written into the cache
                if(mem_ack_i) begin            //wait for data memory acknowledge
                    // TODO: add you code here!
                    //mem_enable <= 1'b1; //YAMASHITA: need to set 1 continuously, because this signal will be used in next state: STATE_READMISS
                    mem_write  <= 1'b0; //YAMASHITA: need to set 0, because this signal was set as 1 in STATE_MISS(when write back)
                    //cache_we   <= 1'b0; //YAMASHITA: This state deals with only memory(reference the 64 page of ppt"Memory-Hiearchy")
                    write_back <= 1'b0; //YAMASHITA:  need to set 0 because already finished writing back to the memory in previous and current state: STATE_MISS and STATE_WRITEBACK, then start to focus on reading data in next state: STATE_READMISS
                    state <= STATE_READMISS;
                end
                //YAMASHITA: wait for data memory acknowledge
                else begin
                    state <= STATE_WRITEBACK;
                end
            end
        endcase
    end
end

//
// Tag SRAM 0
//
dcache_tag_sram dcache_tag_sram
(
    .clk_i(clk_i),
    .addr_i(cache_sram_index),
    .data_i(cache_sram_tag),
    .enable_i(cache_sram_enable),
    .write_i(cache_sram_write),
    .data_o(sram_cache_tag)
);

//
// Data SRAM 0
//
dcache_data_sram dcache_data_sram
(
    .clk_i(clk_i),
    .addr_i(cache_sram_index),
    .data_i(cache_sram_data),
    .enable_i(cache_sram_enable),
    .write_i(cache_sram_write),
    .data_o(sram_cache_data)
);

endmodule
