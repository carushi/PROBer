CC = g++
CFLAGS = -Wall -c -I.
COFLAGS = -Wall -O3 -ffast-math -c -I.
PROGRAMS = dms-seq-extract-reference-transcripts dms-seq-synthesis-reference-transcripts dms-seq-preref

.PHONY : all clean

all : $(PROGRAMS)

sam/libbam.a :
	cd sam ; $(MAKE) all

Transcript.cpp : utils.h my_assert.h Transcript.hpp

Transcript.o : Transcript.cpp utils.h my_assert.h Transcript.hpp
	$(CC) $(COFLAGS) $<

Transcripts.hpp : Transcript.hpp

Transcripts.cpp : utils.h my_assert.h Transcript.hpp Transcripts.hpp

Transcripts.o : Transcripts.cpp utils.h my_assert.h Transcript.hpp Transcripts.hpp 
	$(CC) $(COFLAGS) $<

extractRef.o : extractRef.cpp utils.h my_assert.h GTFItem.h Transcript.hpp Transcripts.hpp
	$(CC) $(COFLAGS) $<

dms-seq-extract-reference-transcripts : Transcript.o Transcripts.o extractRef.o
	$(CC) -O3 -o $@ $^

synthesisRef.o : synthesisRef.cpp utils.h my_assert.h Transcript.hpp Transcripts.hpp
	$(CC) $(COFLAGS) $<

dms-seq-synthesis-reference-transcripts : Transcript.o Transcripts.o synthesisRef.o
	$(CC) -O3 -o $@ $^

RefSeq.cpp : RefSeq.hpp

RefSeq.o : RefSeq.cpp RefSeq.hpp
	$(CC) $(COFLAGS) $<

Refs.hpp : RefSeqPolicy.h PolyARules.h RefSeq.hpp

Refs.cpp : utils.h my_assert.h RefSeqPolicy.h PolyARules.h RefSeq.hpp Refs.hpp

Refs.o : Refs.cpp utils.h my_assert.h RefSeqPolicy.h PolyARules.h RefSeq.hpp Refs.hpp
	$(CC) $(COFLAGS) $<

preRef.o : preRef.cpp utils.h my_assert.h PolyARules.h RefSeqPolicy.h AlignerRefSeqPolicy.h RefSeq.hpp Refs.hpp
	$(CC) $(COFLAGS) $<

dms-seq-preref : RefSeq.o Refs.o preRef.o
	$(CC) -O3 -o $@ $^

sampling.hpp : boost/random.hpp

DMSTransModel.hpp : utils.h sampling.hpp

DMSTransModel.cpp : utils.h sampling.hpp DMSTransModel.hpp

DMSTransModel.o : DMSTransModel.cpp boost/random.hpp utils.h sampling.hpp DMSTransModel.hpp
	$(CC) $(COFLAGS) $<

MyHeap.hpp : utils.h

DMSWholeModel.hpp : sam/bam.h sampling.hpp DMSTransModel.hpp

DMSWholeModel.cpp : sam/bam.h utils.h my_assert.h MyHeap.hpp DMSWholeModel.hpp

DMSWholeModel.o : DMSWholeModel.cpp sam/bam.h boost/random.hpp utils.h my_assert.h sampling.hpp MyHeap.hpp DMSTransModel.hpp DMSWholeModel.hpp
	$(CC) $(COFLAGS) $<

CIGARstring.hpp : sam/bam.h

SEQstring.hpp : sam/bam.h

SEQstring.cpp : SEQstring.hpp

SEQstring.o : SEQstring.cpp sam/bam.h SEQstring.hpp
	$(CC) $(COFLAGS) $<

BamAlignment.hpp : sam/bam.h sam/sam.h my_assert.h CIGARstring.hpp SEQstring.hpp QUALstring.hpp

BamAlignment.cpp : sam/bam.h sam/sam.h my_assert.h SEQstring.hpp BamAlignment.hpp

BamAlignment.o : BamAlignment.cpp sam/bam.h sam/sam.h my_assert.h CIGARstring.hpp SEQstring.hpp QUALstring.hpp BamAlignment.hpp
	$(CC) $(COFLAGS) $<

AlignmentGroup.hpp : sam/sam.h SEQstring.hpp QUALstring.hpp BamAlignment.hpp

SamParser.hpp : sam/sam.h BamAlignment.hpp AlignmentGroup.hpp

SamParser.cpp : sam/sam.h my_assert.h SamParser.hpp

SamParser.o : SamParser.cpp sam/bam.h sam/sam.h my_assert.h CIGARstring.hpp SEQstring.hpp QUALstring.hpp BamAlignment.hpp AlignmentGroup.hpp SamParser.hpp
	$(CC) $(COFLAGS) $<

dms_learning_from_real.o : dms_learning_from_real.cpp sam/bam.h sam/sam.h boost/random.hpp utils.h my_assert.h sampling.hpp CIGARstring.hpp SEQstring.hpp QUALstring.hpp BamAlignment.hpp AlignmentGroup.hpp SamParser.hpp MyHeap.hpp DMSTransModel.hpp DMSWholeModel.hpp
	$(CC) $(COFLAGS) $<

dms_learning_from_real : DMSTransModel.o DMSWholeModel.o SEQstring.o BamAlignment.o SamParser.o dms_learning_from_real.o sam/libbam.a
	$(CC) -O3 -o $@ $^ -lz -lpthread

dms_simulate_reads.o : dms_simulate_reads.cpp boost/random.hpp utils.h my_assert.h sampling.hpp MyHeap.hpp DMSTransModel.hpp DMSWholeModel.hpp
	$(CC) $(COFLAGS) $<

dms_simulate_reads : DMSTransModel.o DMSWholeModel.o dms_simulate_reads.o
	$(CC) -O3 -o $@ $^  -lpthread

dms_learning_from_simulated.o : dms_learning_from_simulated.cpp sam/bam.h boost/random.hpp utils.h my_assert.h sampling.hpp MyHeap.hpp DMSTransModel.hpp DMSWholeModel.hpp
	$(CC) $(COFLAGS) $<

dms_learning_from_simulated : DMSTransModel.o DMSWholeModel.o dms_learning_from_simulated.o sam/libbam.a
	$(CC) -O3 -o $@ $^ -lz -lpthread

clean :
	rm -rf $(PROGRAMS) *.o *~
	cd sam ; $(MAKE) clean


