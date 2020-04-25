module #(
  parameter DATA_WIDTH_P = 8,
  parameter BAUD_P       = 115200
)(
  input   wire clk, // 100 MHz
  input   wire reset,
  input   [DATA_WIDTH_P-1:0] i_data,
  input   wire i_en,
  output  wire o_tx);

  //----------------------------------------------------------------------------
  // local parameter declarations
  //----------------------------------------------------------------------------
  
  // RX states
  localparam
    TX_IDLE     = 2'b00;
    TX_START    = 2'b01;
    TX_DATA     = 2'b10;
    TX_END      = 2'b11;
  
  // counters
  localparam
    CYC_PER_BIT    = (100*10**8/BAUD_P)-1;
    CYC_HALF_BIT   = CYC_HALF_BIT/2;
    CYC_COUNTER_WIDTH    = $clog2(CYC_PER_BIT);

  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // reg and wire declarations
  //----------------------------------------------------------------------------

  reg [1:0] tx_state;
  reg [CYC_COUNTER_WIDTH-1:0] cycle_counter = {CYC_COUNTER_WIDTH{1'b0}};
  reg bit_counter = DATA_WIDTH_P-1;
  reg [DATA_WIDTH_P-1:0] data_reg = {DATA_WIDTH_P{1'b0}};
  reg rx_reg;
  reg valid;
  reg tx;
  
  
  //----------------------------------------------------------------------------

  //----------------------------------------------------------------------------
  // processes and assignments
  //----------------------------------------------------------------------------


  always @(posedge clk) begin
    case (tx_state)
      TX_IDLE : begin
        if (i_en) begin
          tx_state <= TX_START;
          data_reg <= i_data;
        end;
      end
      TX_START : begin
        tx <= 1'b0;
        if (cycle_counter == CYC_PER_BIT) begin
          tx_state <= TX_DATA;
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
        end else begin
          cycle_counter <= cycle_counter + 1;
        end;
      end
      TX_DATA : begin
        tx <= data_reg[0];
        if (cycle_counter == CYC_PER_BIT) begin
          bit_counter <= bit_counter - 1;
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
          if(bit_counter == 0) begin
            tx_state <= TX_END;
            bit_counter <= 0;
          end else begin
            data_reg <= {1'b0,data_reg[DATA_WIDTH_P-1:1]};
          end
        end else 
          cycle_counter <= cycle_counter + 1;
        end;
      end
      TX_END : begin
        tx <= 1'b1;
        if (cycle_counter == CYC_PER_BIT) begin
          tx_state <= TX_IDLE;
          cycle_counter <= {CYC_COUNTER_WIDTH{1'b0}};
          bit_counter <= 0;
        end else 
          cycle_counter <= cycle_counter + 1;
        end;
      end
    endcase
  end

  assign o_tx = tx;

  //----------------------------------------------------------------------------


endmodule