/*
 * A seven segment decoder.
 */
module seven_seg_control#(
        parameter int unsigned DIVISOR = 1,
        parameter byte unsigned DIGITS = 4
    )
    (
        input wire clk,
        output wire [DIGITS-1:0] digit_select,
        output wire [7:0] seg,
        input byte unsigned digits [DIGITS-1:0]
    );

    /*
     * Divide clock.
     */
    logic seven_seg_clk;
    clock_divider #(.DIVISOR(DIVISOR))
        seven_seg_clock_divider
    (
        .clk_in(clk), .clk_out(seven_seg_clk)
    );

    /*
     * Rotator registers.
     */
    logic [$clog2(DIGITS)-1:0] digit_index = 0;
    logic [DIGITS-1:0] digit_select_decoded;
    logic [DIGITS-1:0] digit_select_reg = 'b1111;
    byte unsigned current_digit = 0;
    assign digit_select = digit_select_reg;

    /*
     * Decode digit index into digit-select bitmap.
     */
    decoder digit_select_decoder(
        .in(digit_index), .out(digit_select_decoded)
    );

    /*
     * Rotate through each digit, displaying it on the corresponding
     * digit display.
     */
    always @(posedge seven_seg_clk) begin
        if (digit_index == DIGITS - 1) begin
            digit_index <= 0;
        end
        else begin
            digit_index <= digit_index + 1;
        end

        current_digit <= digits[digit_index];
        digit_select_reg <= ~digit_select_decoded;
    end

    /*
     * Decoder registers.
     */
    logic [7:0] seg_out;
    assign seg = seg_out;

    /*
     * Decode the current digit into the segment bitmap.
     */
    always_comb begin
        case (current_digit)
            "a", "A":
                seg_out <= 'b10001000;
            "c", "C":
                seg_out <= 'b10100111;
            "d", "D":
                seg_out <= 'b10100001;
            "e", "E":
                seg_out <= 'b10000110;
            "h", "H":
                seg_out <= 'b10001001;
            "i", "I":
                seg_out <= 'b11111001;
            "l", "L":
                seg_out <= 'b11000111;
            "n", "N":
                seg_out <= 'b10101011;
            "o", "O":
                seg_out <= 'b11000000;
            "r", "R":
                seg_out <= 'b10101111;
            "s", "S":
                seg_out <= 'b10010010;
            "t", "T":
                seg_out <= 'b10000111;
            "u", "U":
                seg_out <= 'b11100011;
            default:
                seg_out <= 'b11111111;
        endcase
    end

endmodule