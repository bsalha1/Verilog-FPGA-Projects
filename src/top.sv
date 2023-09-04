`timescale 1ns / 1ps

module top(
        input wire clk,
        output wire [15:0] led,
        input wire uart_rx,
        output wire uart_tx,
        output wire [3:0] display1_digit_select,
        output wire [7:0] display1_seg,
        output wire [3:0] display2_digit_select,
        output wire [7:0] display2_seg
    );

    /*
     * Frequency of "clk". Usually the user would know this and then
     * program the BAUD_DIVISOR accordingly to get the right BAUD_RATE,
     * but since there is no compute node here, we explicitly define it.
     */
    localparam CLK_FREQ_HZ = 100_000_000;

    /*
     * Blinking LED.
     */
    localparam BLINK_FREQ_HZ = 2;
    clock_divider #(
        .DIVISOR(CLK_FREQ_HZ / BLINK_FREQ_HZ)
    ) led_blink (
            .clk_in(clk),
            .clk_out(led[0])
        );

    /*
     * Seven-segment display interface.
     */

    byte unsigned digits[7:0];
    initial begin
        digits[7] = "S";
        digits[6] = "A";
        digits[5] = "R";
        digits[4] = "D";
        digits[3] = "I";
        digits[2] = "N";
        digits[1] = "E";
        digits[0] = "S";
    end

    /*
     * Frame rate for each digit in Hz.
     */
    localparam FRAME_RATE = 60;

    /*
     * Number of digits per seven-segment display.
     */
    localparam DIGITS = 4;

    seven_seg_control #(
        .DIVISOR(CLK_FREQ_HZ / FRAME_RATE / DIGITS / 2),
        .DIGITS(DIGITS)
    ) seven_seg1_control (
            .clk(clk),
            .digit_select(display1_digit_select),
            .seg(display1_seg),
            .digits(digits[3:0])
        );

    seven_seg_control #(
        .DIVISOR(CLK_FREQ_HZ / FRAME_RATE / DIGITS / 2),
        .DIGITS(DIGITS)
    ) seven_seg2_control (
            .clk(clk),
            .digit_select(display2_digit_select),
            .seg(display2_seg),
            .digits(digits[7:4])
        );

    /*
     * UART interface.
     */

    localparam UART_BAUD_RATE = 9600;
    localparam UART_FRAME_SIZE = 8;
    logic [UART_FRAME_SIZE-1:0] uart_rx_data;
    logic uart_rx_complete;

    uart_rx_control #(
        .BAUD_DIVISOR(CLK_FREQ_HZ / UART_BAUD_RATE),
        .OVERSAMPLING(16),
        .FRAME_SIZE(UART_FRAME_SIZE)
    ) uart1_rx_control (
            .clk(clk),
            .rx(uart_rx),
            .rx_data(uart_rx_data),
            .rx_complete(uart_rx_complete)
        );

    uart_tx_control #(
        .BAUD_DIVISOR(CLK_FREQ_HZ / UART_BAUD_RATE),
        .FRAME_SIZE(UART_FRAME_SIZE)
    ) uart1_tx_control (
            .clk(clk),
            .tx(uart_tx),
            .tx_data(uart_rx_data),
            .tx_start(uart_rx_complete)
        );

endmodule
