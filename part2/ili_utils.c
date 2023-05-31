#include <asm/desc.h>

void my_store_idt(struct desc_ptr *idtr) {
asm volatile("sidt %0" : "=m" (*idt_ptr));
}

void my_load_idt(struct desc_ptr *idtr) {
asm volatile("lidt %0" : : "m" (*idt_ptr));
}

void my_set_gate_offset(gate_desc *gate, unsigned long addr) {
gate->offset_low = addr;
gate->offset_mid = addr >> 16;
gate->offset_high = addr >> 32;
}

unsigned long my_get_gate_offset(gate_desc *gate) {
unsigned long address = gate->offset_high;
address = address << 16;
address += gate->offset_mid;
address = address << 16;
address += gate->offset_low;
return address;
}
