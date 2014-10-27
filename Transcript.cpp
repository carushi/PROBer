#include<cassert>
#include<string>
#include<vector>
#include<fstream>

#include "utils.h"
#include "my_assert.h"
#include "Transcript.hpp"

//gseq : genomic sequence
void Transcript::extractSeq(const std::string& gseq, std::string& seq) const {
	seq = "";
	int s = structure.size();

	general_assert(structure[0].start >= 1 && structure[s - 1].end <= (int)gseq.length(), "Transcript " + transcript_id + " is out of chromosome " + seqname + "'s boundary!");
 
	switch(strand) {
	case '+':
		for (int i = 0; i < s; i++) {
			seq += gseq.substr(structure[i].start - 1, structure[i].end - structure[i].start + 1); // gseq starts from 0!
		}
		break;
	case '-':
		for (int i = s - 1; i >= 0; i--) {
			for (int j = structure[i].end; j >= structure[i].start; j--) {
				seq += base2rbase[gseq[j - 1]];
			}
		}
		break;
	default: assert(false);
	}

	assert(seq.length() > 0);
}

void Transcript::read(std::ifstream& fin) {
	int s;
	std::string tmp;

	std::getline(fin, transcript_id);
	std::getline(fin, gene_id);
	std::getline(fin, seqname);
	fin>>tmp>>length;
	assert(tmp.length() == 1 && (tmp[0] == '+' || tmp[0] == '-'));
	strand = tmp[0];
	structure.clear();
	fin>>s;
	for (int i = 0; i < s; i++) {
		int start, end;
		fin>>start>>end;
		structure.push_back(Interval(start, end));
	}
	std::getline(fin, tmp); //get the end of this line
	std::getline(fin, left);
}

void Transcript::write(std::ofstream& fout) {
	int s = structure.size();

	fout<<transcript_id<<std::endl;
	fout<<gene_id<<std::endl;
	fout<<seqname<<std::endl;
	fout<<strand<<" "<<length<<std::endl;
	fout<<s;
	for (int i = 0; i < s; i++) fout<<" "<<structure[i].start<<" "<<structure[i].end;
	fout<<std::endl;
	fout<<left<<std::endl;
}
