package waymux;
typedef enum bit {
    use_hit  = 1'b1
    ,use_LRU  = 1'b0
} waymux_sel_t;
endpackage

package cacheinmux;
typedef enum bit {
    use_mem  = 1'b1
    ,use_cpu  = 1'b0
} cacheinmux_sel_t;
endpackage