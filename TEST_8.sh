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
rm -f TEST_1.xyz

# Create the system to analize file TEST_1.xyz
touch TEST_1.xyz
echo '4'                       >> TEST_1.xyz
echo '4.0 4.0 4.0'             >> TEST_1.xyz
echo 'Ar    1.5    0.0    0.0' >> TEST_1.xyz
echo 'Ar   -1.5    0.0    0.0' >> TEST_1.xyz
echo 'Ne    0.5    0.0    0.0' >> TEST_1.xyz
echo 'Ne   -0.5    0.0    0.0' >> TEST_1.xyz





# Create the correct result to compare with kk
rm -f Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 2 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 0 1 ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 0 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 1 TH LARGEST CLUSTER EQUALS 1 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 1 ' >> Correct_Result.dat
echo 'CLUSTERING RESULTS AT TIME 0.000000 : NUMBER OF ATOMS IN 2 TH LARGEST CLUSTER EQUALS 1 ' >> Correct_Result.dat
echo 'INDICES OF ATOMS : 0 ' >> Correct_Result.dat



source /home/carles/Documents/mycodes/plumed2/sourceme.sh


echo "Running TEST-8"
echo "* Checks the overlap and integration of sea kernels controlled by SIGMA"
rm -f kk.dat

#cp PLUMED_1_CLUSTER plumed.dat

rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NOPBC NODES=1-2 ATOMS=3-4 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  D_0=0.0 R_0=0.001 D_MAX=0.002} SWITCH={RATIONAL D_0=20.0 R_0=10.0 D_MAX=50.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=1.0 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=1.28 R_0=0.000001 D_MAX=1.280001}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo ' ' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat

mpirun -np 1 plumed  driver --ixyz TEST_1.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k

rm -f Cluster_*.dat


rm -f plumed.dat
touch plumed.dat
echo 'mat: TOPOLOGY_MATRIX NOPBC NODES=1-2 ATOMS=3-4 BIN_SIZE=1.0 CYLINDER_SWITCH={RATIONAL  D_0=0.0 R_0=0.001 D_MAX=0.002} SWITCH={RATIONAL D_0=20.0 R_0=10.0 D_MAX=50.0} RADIUS={RATIONAL D_0=0.5 R_0=0.000001 D_MAX=0.6} SIGMA=1.0 KERNEL=triangular DENSITY_THRESHOLD={RATIONAL D_0=1.26 R_0=0.000001 D_MAX=1.2600001}' >> plumed.dat
echo 'DFSCLUSTERING MATRIX=mat LABEL=ss1' >> plumed.dat
echo ' ' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=1 FILE=Cluster_1.dat' >> plumed.dat
echo 'OUTPUT_CLUSTER CLUSTERS=ss1 CLUSTER=2 FILE=Cluster_2.dat' >> plumed.dat


mpirun -np 1 plumed  driver --ixyz TEST_1.xyz > garbage
cat Cluster_1.dat  Cluster_2.dat  >> k

diff -b Correct_Result.dat k


#http://misc.flogisoft.com/bash/tip_colors_and_formatting
if diff -b Correct_Result.dat k >/dev/null ; then
  echo -e '\e[42m\e[97m    TEST-8    PASSED SUCCESSFULLY    \033[0m'
else
  echo -e '\e[41m\e[97m    TEST-8    FAILED    \033[0m'
fi
#rm -f bck.* k
rm -f *~
rm -f Cluster_*.dat
rm -f plumed.dat
rm -f TEST_1.xyz
rm -f garbage
#rm -f Correct_Result.dat
