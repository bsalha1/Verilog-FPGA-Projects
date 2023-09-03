`timescale 1ns / 1ps


module uart_rx_tb(

    );

    logic clk = 0;
    logic tx_in = 0;
    logic [7:0] data = 0;
    logic rx = 0;
    logic rx_complete = 0;
    logic tx_out = 0;
    
    // 100 MHz clock
    always #10 clk = ~clk;

    // 100 MHz / 10417 = ~9600 Hz
    always #208340 tx_in = ~tx_in;

    uart_rx_control #(
        .BAUD_DIVISOR(10417),
        .OVERSAMPLING(8),
        .FRAME_SIZE(8)
        ) uart1_rx_control (
            .clk(clk),
            .rx(tx_in),
            .rx_data(data),
            .rx_complete(rx_complete)
        );

   uart_tx_control #(
        .BAUD_DIVISOR(10417),
        .FRAME_SIZE(8)
        ) uart1_tx_control (
        .clk(clk),
        .tx(tx_out),
        .data(data),
        .tx_start(rx_complete)
    );

endmodule