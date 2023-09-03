`timescale 1ns / 1ps

module uart_tx_control
    #(
        parameter int unsigned BAUD_DIVISOR = 1024,
        parameter byte unsigned FRAME_SIZE = 8
    )
    (
        input wire clk,
        output wire tx,
        input logic [FRAME_SIZE-1:0] tx_data,
        input wire tx_start
    );

    /*
     * Generate the clock that ticks the UART TX interface. This will
     * run at freq = 2 * baud rate
     */
    logic tx_clk;
    clock_divider #(.DIVISOR(BAUD_DIVISOR / 2))
        tx_clk_divider
    (
        .clk_in(clk), .clk_out(tx_clk)
    );

    /*
     * Sample tx_start from the clk domain to tx_clk domain by extending a high tx_start pulse
     * in the clk domain to one period in the tx_clk domain.
     */
    logic tx_start_tx_clk = 0;
    longint tx_start_persistence = 0;
    always @(posedge clk) begin

        /*
         * When tx_start goes high, initialize the persistence counter.
         */
        if (tx_start) begin
            tx_start_persistence <= 0;
            tx_start_tx_clk <= 1;
        end
        /*
         * When tx_start is low, increment the persistence timer until
         * it reaches the period of tx_clk, then push tx_start in the tx_clk
         * domain low.
         */
        else begin
            if (tx_start_persistence == (BAUD_DIVISOR - 1)) begin
                tx_start_tx_clk <= 0;
            end
            else begin
                tx_start_persistence <= tx_start_persistence + 1;
            end
        end
    end

    /*
     * State machine state.
     */
    typedef enum {IDLE, START_BIT, DATA, STOP_BIT} uart_state;
    uart_state state = IDLE;

    /*
     * State machine variables
     */
    byte unsigned bit_index = 0;

    /*
     * Latch internal TX line to output.
     */
    logic tx_out = 0;
    assign tx = tx_out;

    /*
     * UART TX state machine.
     */
    always @(posedge tx_clk) begin
        case (state)

            IDLE: begin

                /*
                 * Push TX line high.
                 */
                tx_out <= 1;

                /*
                 * Reset all the stateful variables.
                 */
                bit_index <= 0;

                /*
                 * When requested to start a TX, go to START_BIT.
                 */
                if (tx_start_tx_clk == 1) begin
                    state <= START_BIT;
                end
            end

            START_BIT: begin

                /*
                 * Pull TX line low.
                 */
                tx_out <= 0;
                state <= DATA;
            end

            DATA: begin

                /*
                 * Latch TX data to TX line.
                 */
                tx_out <= tx_data[bit_index];

                /*
                 * If we transmitted all the bits of the frame, go to STOP_BIT state.
                 */
                if (bit_index == (FRAME_SIZE - 1)) begin
                    state <= STOP_BIT;
                end
                else begin
                    bit_index = bit_index + 1;
                end
            end

            STOP_BIT: begin

                /*
                 * Push TX line high and go to IDLE state.
                 */
                tx_out <= 1;
                state <= IDLE;
            end
        endcase
    end
    endmodule