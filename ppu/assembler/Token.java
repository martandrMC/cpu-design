public class Token {

	private String opcode, operand1, operand2;
	private String op1type, op2type;
	private static final String[] valid_opcodes = {"LDI", "LOD", "STR", "MOV", "LDP", 
			"ADD", "ADC", "SUB", "SBC", "RSH", "RSC", "AND", "IOR", "NOR", "XOR", "NND", "NPL",
			"JMP", "BRC", "BRV", "BRZ", "HLT", "NOP"};
	
	public Token(String opcode, String operand1, String operand2) throws AssemblyException {
		this.opcode = opcode;
		if(!validateOpcode(opcode)) throw new AssemblyException("Unrecognised opcode \'"+opcode+"\'");
		
		op1type = validateOperand(operand1);
		this.operand1 = operand1;
		if(op1type.equals("u")) throw new AssemblyException("Invalid first operand type \'"+operand1+"\'");
		
		op2type = validateOperand(operand2);
		this.operand2 = operand2;
		if(op2type.equals("u")) throw new AssemblyException("Invalid second operand type \'"+operand2+"\'");
		
		int errcode = validateToken();
		if((errcode&1) != 0) throw new AssemblyException("Incompatible first operand \'"+operand1+"\' with instruction \'"+opcode+"\'");
		if((errcode&2) != 0) throw new AssemblyException("Incompatible second operand \'"+operand2+"\' with instruction \'"+opcode+"\'");
	}
	
	@SuppressWarnings("unused")
	private String optypestr(String optype) {
		switch(optype) {
			case "rn": return "Numeric Register Address";
			case "rl": return "Letter Register Address";
			case "ih": return "Small Hex Literal";
			case "Ih": return "Large Hex Literal";
			case "ib": return "Small Binary Literal";
			case "Ib": return "Large Binary Literal";
			case "id": return "Small Decimal Literal";
			case "Id": return "Large Decimal Literal";
			case "Il": return "Unresolved Label";
			case "u": return "Undefined";
			default: return "";
		}
	}

	private boolean validateOpcode(String opcode) {
		boolean flag = false;
		for(String s : valid_opcodes)
			if(flag = opcode.compareToIgnoreCase(s) == 0) break;
		return flag;
	}
	
	private String validateOperand(String operand) {
		if(operand.isEmpty()) return "";
		else if(operand.matches("^r[0-3]$")) return "rn";
		else if(operand.matches("^[A-D]$")) return "rl";
		else if(operand.matches("^x0*[0-9A-Fa-f]$")) return "ih";
		else if(operand.matches("^x0*[1-3][0-9A-Fa-f]$")) return "Ih";
		else if(operand.matches("^b0*[01]{1,4}$")) return "ib";
		else if(operand.matches("^b0*[01]{1,6}$")) return "Ib";
		else if(operand.matches("^0*(1[0-5]|\\d)$")) return "id";
		else if(operand.matches("^0*(6[0-3]|[1-5]\\d|\\d)$")) return "Id";
		else if(operand.matches(":[A-Za-z0-9-_]+")) return "Il";
		else return "u";
	}
	
	private int validateToken() {
		switch(opcode) {
			case "LDI":
				return (op1type.startsWith("r") ? 0 : 1) + (op2type.startsWith("i") ? 0 : 2);
			case "LOD": case "STR":
				return (op1type.startsWith("r") ? 0 : 1) + (op2type.startsWith("i") || op2type.isEmpty() ? 0 : 2);
			case "LDP":
				return (op1type.startsWith("r") ? 0 : 1) + (op2type.isEmpty() ? 0 : 2);
			case "ADD": case "SUB":
				return (op1type.startsWith("r") ? 0 : 1) + (op2type.startsWith("r") || op2type.startsWith("i") ? 0 : 2);
			case "MOV": case "ADC": case "SBC": case "RSH": case "RSC": case "AND":
			case "IOR": case "NOR": case "XOR": case "NND": case "NPL":
				return (op1type.startsWith("r") ? 0 : 1) + (op2type.startsWith("r") ? 0 : 2);
			case "JMP": case "BRC": case "BRV": case "BRZ":
				return (op1type.startsWith("r") || op1type.startsWith("I") || op1type.startsWith("i") ? 0 : 1) + (op2type.isEmpty() ? 0 : 2);
			case "HLT": case "NOP":
				return (op1type.isEmpty() ? 0 : 1) + (op2type.isEmpty() ? 0 : 2);
			default: return -1;
		}
	}
	
	private int regBin(boolean which) {
		String op = which ? operand2 : operand1;
		String optype = which ? op2type : op1type;
		if(optype.equals("rn")) return Integer.parseInt(op.substring(1));
		else return (int)(op.charAt(0)) - 65;
	}
	
	private int immBin(boolean which) {
		String op = which ? operand2 : operand1;
		String optype = which ? op2type : op1type;
		if(optype.charAt(1) != 'd') op = op.substring(1);
		if(optype.charAt(1) == 'h') return Integer.parseInt(op, 16);
		else if(optype.charAt(1) == 'b') return Integer.parseInt(op, 2);
		else return Integer.parseInt(op);
	}
	
	public boolean needsLabelResolve() { return op1type.equals("Il"); }
	public String getLabel() { return operand1; }
	public void resolveLabel(String op) {
		op1type = validateOperand(op);
		operand1 = op;
	}
	
	public short getBinary() throws AssemblyException {
		if(op1type == "Il") throw new AssemblyException("Unresolved label \'"+operand1.substring(1)+"\'");
		switch(opcode) {
			case "LDI": return (short)( regBin(false)<<4 | immBin(true) );
			case "LOD":
				if(op2type.isEmpty()) return (short)( 3<<6 | regBin(false)<<2 );
				else return (short)( 1<<6 | regBin(false)<<4 | immBin(true) );
			case "STR":
				if(op2type.isEmpty()) return (short)( 3<<6 | 1<<4 | regBin(false) );
				else return (short)( 2<<6 | regBin(false)<<4 | immBin(true) );
			case "LDP": return (short)( 3<<6 | 3<<4 | regBin(false) );
			case "ADD":
				if(op2type.charAt(0) == 'r') return (short)( 1<<8 | 2<<6 | regBin(false)<<2 | regBin(true) );
				else return (short)( 1<<8 | regBin(false)<<4 | immBin(true) );
			case "SUB":
				if(op2type.charAt(0) == 'r') return (short)( 1<<8 | 2<<6 | 2<<4 | regBin(false)<<2 | regBin(true) );
				else return (short)( 1<<8 | 1<<6 | regBin(false)<<4 | immBin(true) );
			case "MOV": return (short)( 3<<6 | 2<<4 | regBin(false)<<2 | regBin(true) );
			case "ADC": return (short)( 1<<8 | 2<<6 | 1<<4 | regBin(false)<<2 | regBin(true) );		
			case "SBC": return (short)( 1<<8 | 2<<6 | 3<<4 | regBin(false)<<2 | regBin(true) );		
			case "RSH": return (short)( 3<<8 | 1<<6 | regBin(false)<<2 | regBin(true) );			
			case "RSC": return (short)( 3<<8 | 1<<6 | 1<<4 | regBin(false)<<2 | regBin(true) );		
			case "AND": return (short)( 1<<8 | 3<<6 | regBin(false)<<2 | regBin(true) );
			case "IOR": return (short)( 1<<8 | 3<<6 | 1<<4 | regBin(false)<<2 | regBin(true) );
			case "NOR": return (short)( 1<<8 | 3<<6 | 2<<4 | regBin(false)<<2 | regBin(true) );
			case "XOR": return (short)( 1<<8 | 3<<6 | 3<<4 | regBin(false)<<2 | regBin(true) );
			case "NND": return (short)( 3<<8 | 1<<6 | 2<<4 | regBin(false)<<2 | regBin(true) );
			case "NPL": return (short)( 3<<8 | 1<<6 | 3<<4 | regBin(false)<<2 | regBin(true) );		
			case "JMP":
				if(op1type.charAt(0) == 'r') return (short)( 3<<8 | regBin(false) );
				else return (short)( 2<<8 | immBin(false) );
			case "BRC":
				if(op1type.charAt(0) == 'r') return (short)( 3<<8 | 1<<4 | regBin(false) );
				else return (short)( 2<<8 | 1<<6 | immBin(false) );
			case "BRV":
				if(op1type.charAt(0) == 'r') return (short)( 3<<8 | 2<<4 | regBin(false) );
				else return (short)( 2<<8 | 2<<6 | immBin(false) );
			case "BRZ":
				if(op1type.charAt(0) == 'r') return (short)( 3<<8 | 3<<4 | regBin(false) );
				else return (short)( 2<<8 | 3<<6 | immBin(false) );
			case "HLT": return (short)( 3<<8 | 2<<6 );
			case "NOP": return (short)( 3<<8 | 3<<6 );
			default: return -1;
		}
	}
}
