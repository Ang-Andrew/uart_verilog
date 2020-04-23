module #(
  parameter DATA_WIDTH_P = 8,
  parameter BAUD_P       = 115200
)(
  input   wire clk, // 100 MHz
  input   wire reset,
  input   wire i_rx,
  output  [DATA_WIDTH_P-1:0] o_data,
  output  wire o_valid);

  //----------------------------------------------------------------------------
  // local parameter declarations
  //----------------------------------------------------------------------------
  
  // RX states
  localparam
    RX_IDLE     = 2'b00;
    RX_START    = 2'b01;
    RX_DATA     = 2'b10;
    RX_END      = 2'b11;
  
  // counters
  localparam
    CYC_PER_BIT    = (100*10**8/BAUD_P)-1;
    CYC_HALF_BIT   = CYC_HALF_BIT/2;
    CYC_COUNTER_WIDTH    = $clog2(CYC_PER_BIT);

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // reg and wire declarations
  //----------------------------------------------------------------------------

  reg [1:0] rx_state;
  reg [CYC_COUNTER_WIDTH-1:0] cycle_counter = {CYC_COUNTER_WIDTH{1'b0}}
  reg bit_counter = 0;
  reg [DATA_WIDTH_P-1:0] data_reg;
  reg rx_reg;
  reg valid;
  reg [DATA_WIDTH_P-1:0] data;
  
  
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // processes and assignments
  //----------------------------------------------------------------------------

  always @(posedge clk) begin
    rx_reg <= i_rx;
    o_valid <= 1'b0;
    case (rx_state)
      RX_IDLE : begin
        // detecting falling edge
        if (rx_reg && !i_rx && !detect_start) begin
          // count until we get to the middle of the start bit
          rx_state <= RX_START;
        end;
      end
      RX_START : begin
        // in start bit, wait till we get to the middle
        if (cycle_counter == CYC_HALF_BIT) begin
          rx_state <= RX_DATA;
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
        end else begin
          cycle_counter <= cycle_counter + 1;
        end;
      end
      RX_DATA : begin
        if (cycle_counter == CYC_PER_BIT) begin
          bit_counter <= bit_counter + 1;
          if(bit_counter == DATA_WIDTH_P-1) begin
            rx_state <= RX_END;
          end
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
          // shift in data into rx register
          rx_reg <= {i_rx,rx_reg[DATA_WIDTH_P-2:0]};
        end else 
          cycle_counter <= cycle_counter + 1;
        end;
      end
      RX_END : begin
        if (cycle_counter == CYC_PER_BIT) begin
          if(i_rx == 1'b1) begin
            rx_state <= RX_IDLE;
          end
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
          bit_counter <= 0;
          valid <= 1'b1;
        end else 
          cycle_counter <= cycle_counter + 1;
        end;
      end
    endcase
  end

  assign o_valid = valid;
  assign o_data = valid ? rx_reg : {DATA_WIDTH_P{1'b0}};

  //----------------------------------------------------------------------------


endmodule