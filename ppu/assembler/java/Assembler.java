import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Scanner;

public class Assembler {
	
	public static void main(String[] args) throws AssemblyException {
		Scanner console = new Scanner(System.in);
		String prev = "";
		while(true) {
			System.out.println("------------------------------");
			System.out.print("Name of file to assemble: ");
			String asmfile = console.nextLine();
			if(asmfile.equals("!exit")) break;
			else if(asmfile.isEmpty() && !prev.isEmpty()) asmfile = prev;
			if(!asmfile.matches(".*\\.ppu")) asmfile += ".ppu";
			System.out.println("[Info] Assembling file \'"+asmfile+"\'");
			String binfile = asmfile.replaceFirst("\\.ppu", ".bin");
			prev = asmfile;
			
			ArrayList<String> lines = readAsmFile(asmfile);
			ArrayList<Token> tokens = tokenizeAsmFile(lines);
			short[] program = generateMachineCode(tokens);
			writeProgramToFile(program, binfile);
		}
		System.out.println("[Info] Exiting...");
		console.close();
	}
	
	public static ArrayList<String> readAsmFile(String asmfile) {
		ArrayList<String> lines = null;
		try {
			int line_counter = 1;
			lines = new ArrayList<String>();
			Scanner file = new Scanner(new File(asmfile));
			while(file.hasNextLine()) {
				String line = file.nextLine().trim().replaceFirst(";.*", "");
				if(!line.isEmpty()) lines.add(line+";"+line_counter);
				line_counter++;
			}
			file.close();
		} catch (FileNotFoundException e) {		
			System.err.println("[Error] Could not read from file \'"+asmfile+"\'");
			System.exit(-1);
		}
		return lines;
	}
	
	public static ArrayList<Token> tokenizeAsmFile(ArrayList<String> lines) {
		ArrayList<String> defined_labels = new ArrayList<String>();
		ArrayList<String> instructions = new ArrayList<String>();
		HashMap<String, Integer> address_map = new HashMap<String, Integer>();
		for(String line : lines) {
			if(line.replaceFirst(";.*", "").matches(":[A-Za-z0-9-_]+")) {
				address_map.put(line, instructions.size());
				defined_labels.add(line);
			}else instructions.add(line);
			if(instructions.size() > 64)
				System.err.println("[Warning] Program can not fit in the processor's program memory address space.");
		}
		System.out.println("[Info] Program uses "+instructions.size()+
				" words of program memory ("+(int)Math.round(instructions.size()*100/64f)+"%)");
		ArrayList<Token> tokens = new ArrayList<Token>();
		for(String instruction : instructions) {
			String[] subtokens = instruction.split("[ ,;]+");
			int line_number = Integer.parseInt(subtokens[subtokens.length-1]);
			try {
				if(subtokens.length > 4) throw new AssemblyException("[Error] Invalid instruction \'"+instruction.replaceFirst(";.*", "")+"\'");
				Token token = new Token(subtokens[0], subtokens.length >= 3 ? subtokens[1] : "", subtokens.length == 4 ? subtokens[2] : "");
				if(token.needsLabelResolve()) {
					for(String l : defined_labels) {
						if(!token.getLabel().equals(l.replaceFirst(";.*", ""))) continue;
						token.resolveLabel(address_map.get(l).toString());
					}
				}
				tokens.add(token);
			}catch (AssemblyException e) {
				System.err.println("[Error] (Line "+line_number+") "+e.getMessage());
			}
		}
		return tokens;
	}
	
	public static short[] generateMachineCode(ArrayList<Token> tokens) {
		short[] program = new short[tokens.size()];
		try { for(int i = 0; i < program.length; i++) program[i] = tokens.get(i).getBinary(); }
		catch (AssemblyException e) { System.err.println("[Error] "+e.getMessage()); }
		return program;
	}
	
	public static void writeProgramToFile(short[] program, String filename) {
		try {
			FileOutputStream file = new FileOutputStream(filename);
			for(short word : program) {
				file.write(word);
				file.write(word>>8);
			}
			file.close();
		} catch (Exception e) {
			System.err.println("[Error] Could not write to file \'"+program+"\'");
		}
	}
}
