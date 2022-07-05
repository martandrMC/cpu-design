# PHINIX

The processor implementation included, while working, does not fully comply with the PHINIX ISA specification. Please beware, **there are still bugs with the forwarding**. Hardware development of this processor has ceased in favor of the development of its improved relative, PHINIX+, for which the ISA will be on many areas identical. If you have written software for the current implementation and you'd like to have it run on PHINIX+ contact me and I will assist you.

If you are to program with the assembler provided and you come across a bug in your program, consider putting 3 NOPs between instructions. If the problem disappears it was a forwarding problem. After you have identified the issue, begin removing NOPs until the problem appears again. One big well known current bug is forwarding problems between repeated post-increment/pre-increment/pre-decrement memory instructions (including push and pop).
