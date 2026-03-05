
#FC = f77
#FC = pgf77
#FC = ifc
#FC = ifort # after ifc8
#FC = efc
#AR = ar


# PGI Fortran77 at (Athlon / Duron)
#
#FFLAGS=-O2 -Minline -Munroll -Mcache_align -Mvect=prefetch
#FFLAGS=-O2 -Minline -Munroll -Mcache_align -Mvect=prefetch -tp athlon
#FFLAGS=-O2 -Minline -Munroll
#FFLAGS=-O0

# ifc ver.7
#
#FFLAGS=-O3 -tpp7 -FI -w -unroll -align -WB
#FFLAGS=-O3 -tpp7 -w -unroll -align
#FFLAGS=-O3 -tpp7 -axW -xW -w90 -w95 -WB -cm -ipo_obj -mp1 -zero -save -unroll -align
#FFLAGS=-O3 -tpp7 -axW -xW -w90 -w95 -WB -cm -ipo_obj -mp1 -zero -save


# intel composuer 2017
#
FC = ifort # after ifc8
FFLAGS=-O -mp1
INSTALL_DIR=../../


# gfortran
#FC = gfortran # after ifc8
#FFLAGS=-O
#INSTALL_DIR=../../


# ifc ver.8
#
#FFLAGS=-O3 -tpp7 -axW -xW -w90 -w95 -WB -cm -ipo_obj -mp1 -quiet
#FFLAGS=-O3 -tpp7 -axW -tune pn4 -arch pn4 -ipo_obj -mp1
#FFLAGS=-O1 -tpp7 -axW -tune pn4 -arch pn4 -ipo_obj -mp1


# efc
#
#FFLAGS=-O0 -w
#FFLAGS=-O3 -w
#FFLAGS=-O3 -tpp2 -w90 -w95 -WB -cm -ipo_obj -mp1 -opt_report -opt_report_levelmax -opt_report_phaseall -opt_report_fileOptF -IPF_fltacc- -IPF_fp_speculationoff -zero -save

# g77 option Fortran 90 interpretation.
#
#FFLAGS=-O4 -ff90
#FFLAGS=-O4 -ff90 -malign-double -funroll-loops

# Digital Fortran (True64/Alpha)
#
#FFLAGS=-O5 -arch host -math_library accurate -pipeline -convert big_endian -align dcommons -inline all -tune host


#PREFIX=/usr/local/apw
#PREFIX=${HOME}/apw/peach
#LIBDIR=$(PREFIX)/lib

#LIB=libtspace.a
#SRC=tspace.f
#OBJ=tspace.o

LIB=libtsp98.a
SRC=tsp98.f
OBJ=tsp98.o

PROJ = $(LIB)

.f.o:
	$(FC) $(FFLAGS) -c $<

all:	$(PROJ)

clean:
	rm -f $(PROJ) $(OBJ) core

$(PROJ):$(OBJ)
	$(AR) -cr $@ $(OBJ)

install:
#	mv $(PROJ) $(BAND)/lib/okayama/$(IAM)/
	mv $(PROJ) $(INSTALL_DIR)
	rm -f *.o

#tspace.o:tspace.f prmtsp.fi
tsp98.o:tsp98.f prmtsp.f

