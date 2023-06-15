package fifo_types;
/***************************** Param Declarations ****************************/
// Width of words (in bits) stored in queue
parameter int width_p = 8;
typedef logic [width_p-1:0] word_t;
// FIFO's don't use shift registers, rather, they use pointers
// which address to the "read" (dequeue) and "write" (enqueue)
// ports of the FIFO's memory
parameter int ptr_width_p = 8;

// Why is the ptr type a bit longer than the "ptr_width"? 
// Make sure you can answer this question by the end of the semester
typedef logic [ptr_width_p:0] ptr_t;

// The number of words stored in the FIFO
parameter int cap_p = 1 << ptr_width_p;

typedef enum {
    // Asserting reset_n @(negedge) should result in ready_o @(posedge)
    RESET_DOES_NOT_CAUSE_READY_O, 
    // When asserting yumi @(negedge), data_o should be the CORRECT value
    INCORRECT_DATA_O_ON_YUMI_I
} error_e;

typedef struct {
    error_e err;
    time ltime;
} error_report_t;

endpackage : fifo_types
