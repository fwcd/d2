import SwiftDiscord
import D2Permissions

public class BFToCCommand: StringCommand {
	public let info = CommandInfo(
		category: .bf,
		shortDescription: "Transpiles a BF program into C code",
		longDescription: "Outputs a C program whose functionality is equivalent to the given BF program",
		requiredPermissionLevel: .basic
	)

	public init() {}
	
	public func invoke(withStringInput input: String, output: CommandOutput, context: CommandContext) {
		if let bfProgram = bfCodePattern.firstGroups(in: input)?[1] {
			var outputCode = ""
			var last: String? = nil
			var repeats: Int = 1
			
			for character in bfProgram {
				let translated: String
				switch character {
					case ">": translated = "p++;"
					case "<": translated = "p--;"
					case "+": translated = "vi(&t,p);"
					case "-": translated = "vd(&t,p);"
					case "/": translated = "vdb(&t,p);"
					case ".": translated = "putchar(vg(&t,p));"
					case ",": translated = "vs(&t,p,getchar());"
					case "[": translated = "while(vg(&t,p)){"
					case "]": translated = "}"
					default: translated = ""
				}
				if translated == last && character != "[" && character != "]" {
					repeats += 1
				} else if last != nil {
					if repeats < 4 {
						outputCode += String(repeating: last ?? "", count: repeats)
					} else {
						outputCode += "for(int i=0;i<\(repeats);i++){\(last ?? "")}"
					}
					repeats = 1
				}
				last = translated
			}
			
			outputCode += String(repeating: last ?? "", count: repeats)
			let outputC = "#include <stdio.h>\n#include <stdlib.h>\ntypedef struct {int *d;int n;int y;} Vec;Vec vn(){Vec vec = {.d = malloc(sizeof(int)*10),.n=0,.y=10};for (int i=0;i<vec.y;i++) vec.d[i]=0;return vec;}void vcp(Vec *v,int nc){if (v->y<nc) {v->d = realloc(v->d, sizeof(int)*nc);for (int i=v->y;i<nc;i++) v->d[i]=0;v->y=nc;}}int indexOf(int p){if(p>=0){return p*2;}else{return(p*-2)-1;};}int vg(Vec *v, int p){int i=indexOf(p);vcp(v,i+10);return v->d[i];}void vs(Vec *v, int p, int value){int i=indexOf(p);vcp(v,i+10);v->d[i]=value;}void vi(Vec *v, int p){int i=indexOf(p);vcp(v,i+10);v->d[i]++;}void vd(Vec *v, int p) {int i=indexOf(p);vcp(v,i+10);v->d[i]--;}void vdb(Vec *v, int p) {int i=indexOf(p);vcp(v,i+10);v->d[i]*=2;}void vdl(Vec *v) {free(v->d);}int main(void) {Vec t=vn();int p=0;\(outputCode)vdl(&t);return 0;}"
			
			if let lengthLimit = output.messageLengthLimit {
				for chunk in outputC.split(by: lengthLimit) {
					output.append("```c\n\(chunk)\n```")
				}
			} else {
				output.append("```c\n\(outputC)\n```")
			}
		}
	}
}
