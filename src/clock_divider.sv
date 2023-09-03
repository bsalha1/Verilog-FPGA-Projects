`timescale 1ns / 1ps

module clock_divider
    #(
        parameter int unsigned DIVISOR = 1
    )
    (
        input wire clk_in,
        output wire clk_out
    );

    int unsigned counter = 0;
    logic clk_out_reg = 0;

    assign clk_out = clk_out_reg;

    /*
     * At each rising edge of the input clock, increment the counter. If the counter
     * reaches the divisor, then toggle the output clock and reset the counter.
     */
    always_ff @(posedge clk_in) begin
        if (counter == (DIVISOR - 1)) begin
            counter <= 0;
            clk_out_reg <= ~clk_out_reg;
        end
        else begin
            counter <= counter + 1;
        end
    end

endmodule
