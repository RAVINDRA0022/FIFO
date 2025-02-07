`timescale 1ns / 1ps

module async_fifo #( parameter DATA_WIDTH = 8 ,
                     parameter FIFO_DEPTH = 90)(
                     input wr_clk,
                     input rd_clk,
                     input rst_n,
                     input wr_en,
                     input rd_en,
                     input [DATA_WIDTH-1:0] wr_data,
                     output [DATA_WIDTH-1:0] rd_data,
                     output full,
                     output empty );
                reg [DATA_WIDTH-1:0] mem [0:FIFO_DEPTH-1];
                reg[4:0] wr_ptr ,rd_ptr;
                reg[4:0] wr_ptr_gray,rd_ptr_gray; 
                reg[4:0] wr_ptr_gray_rd_clk,rd_ptr_gray_wr_clk;
                wire fifo_full,fifo_empty;
                   always @(posedge wr_clk or negedge rst_n)
                   begin  
                     if(!rst_n)
                     begin  
                     wr_ptr <= 0;
                     wr_ptr_gray <= 0;
                     end 
                     else if(wr_en && !fifo_full) 
                     begin
                     mem[wr_ptr[4:0]] <= wr_data;
                     wr_ptr <= wr_ptr + 1 ; 
                     wr_ptr_gray <= (wr_ptr + 1 ) ^ ((wr_ptr + 1 ) >> 1);
                  end
                 end  
                       always @(posedge rd_clk or negedge rst_n)
                     begin  
                        if(!rst_n)
                        begin    
                        rd_ptr <= 0 ;
                        rd_ptr_gray <= 0 ;
                        end
                        else if(rd_en && !fifo_empty)
                        begin 
                        rd_ptr <= rd_ptr + 1 ;
                        rd_ptr_gray <= ( rd_ptr + 1 ) ^ ((rd_ptr + 1 ) >> 1);
                        end 
                      end
                          always @(posedge wr_clk or negedge rst_n) begin
                               if (!rst_n)
                                 rd_ptr_gray_wr_clk <= 0;
                               else
                                  rd_ptr_gray_wr_clk <= rd_ptr_gray;
                               end

                         always @(posedge rd_clk or negedge rst_n) begin
                          if (!rst_n)
                             wr_ptr_gray_rd_clk <= 0;
                           else
                             wr_ptr_gray_rd_clk <= wr_ptr_gray;
                            end
      assign fifo_full = (wr_ptr_gray == {~rd_ptr_gray_wr_clk[4:3],rd_ptr_gray_wr_clk[2:0]});
      assign fifo_empty = (rd_ptr_gray == wr_ptr_gray_rd_clk);         
      assign full = fifo_full;
      assign empty = fifo_empty;
    endmodule
