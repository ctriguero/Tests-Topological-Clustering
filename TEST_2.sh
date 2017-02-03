#!/bin/bash

# In this test we check a basic fact:

# A system with two nodes and 1 sea atom between them at a minimal distance aligned.
 
# The sea atom is placed at 0 and the nodes at -1 and 1. We assume da=1. setting binsize=2. 
# Then a single cylinder is set between the only two existing nodes. The density detected in
# this cylinder should be:
# \rho=1/(2*pi*da/2)=1/(2*pi*0.5)=0.636619.

# The test is the following:
# Setting \rho_T=0.6 =>  \rho_T < \rho A SINGLE CLUSTER SHOULD BE DETECTED.
# Setting \rho_T=0.7 =>  \rho_T > \rho TWO CLUSTERS SHOULD BE DETECTED.

rm -f bck.* k
rm -f *~
rm -f Cluster_*.dat
rm -f plumed.dat


# Create the system to analize file TEST_2.xyz
rm -f TEST_2.xyz
touch TEST_2.xyz
echo '3'                       >> TEST_2.xyz
echo '3.0 1.0 1.0'             >> TEST_2.xyz
echo 'Ar    1.0    0.0    0.0' >> TEST_2.xyz
echo 'Ar   -1.0    0.0    0.0' >> TEST_2.xyz
echo 'Ne    0.0    0.0    0.0' >> TEST_2.xyz


# Create the correct result to compare with kk
rm -f Correct.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 2 ' >> Correct.dat
echo 'INDICES OF ATOMS : 0 1 ' >> Correct.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 0 ' >> Correct.dat
echo 'INDICES OF ATOMS : ' >> Correct.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 1 ' >> Correct.dat
echo 'INDICES OF ATOMS : 1 ' >> Correct.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 1 ' >> Correct.dat
echo 'INDICES OF ATOMS : 0' >> Correct.dat


source /home/carles/Documents/mycodes/plumed2/sourceme.sh

echo "Running TEST-2"
rm -f kk.dat

#cp PLUMED_1_CLUSTER plumed.dat
rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NOPBC NODES=1-2 ATOMS=3-3 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  R_0=0.000001 D_MAX=0.1} SWITCH={RATIONAL D_0=10.0 R_0=0.5 D_MAX=15.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=0.5 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=0.65 R_0=0.000001 D_MAX=1.5}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo ' ' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat

# Run first cutoff
mpirun -np 1 plumed  driver --ixyz TEST_2.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k

rm -f Cluster_*.dat garbage

#cp PLUMED_2_CLUSTERS plumed.dat
rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NOPBC NODES=1-2 ATOMS=3-3 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  R_0=0.000001 D_MAX=0.1} SWITCH={RATIONAL D_0=10.0 R_0=0.5 D_MAX=15.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=0.5 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=0.61 R_0=0.000001 D_MAX=1.5}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat

# Run second cutoff
mpirun -np 1 plumed  driver --ixyz TEST_2.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k
rm -f plumed.dat garbage

diff -b Correct.dat k

#clear

#http://misc.flogisoft.com/bash/tip_colors_and_formatting

if diff -b Correct.dat k >/dev/null ; then
  echo -e '\e[42m\e[97m    TEST-2    PASSED SUCCESSFULLY    \033[0m'
  #echo -e '\E[37;44m'"\033[1mContact List\033[0m"
  #echo -e '\E[47;32m'"\033[1mS\033[0m"   # Green
else
  echo -e '\e[41m\e[97m    TEST-2    FAILED    \033[0m'
fi
rm -f bck.* k
rm -f *~
rm -f Cluster_*.dat
rm -f plumed.dat
rm -f TEST_2.xyz
rm -f Correct.dat
