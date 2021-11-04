# small script to add the markdown publication files to the individual team member markdown files 
# this is done in the CI to keep the original team member md files clean

for MD in docs/team/*.publications.md; do
    BN=$(basename $MD .publications.md)
    echo "cat $MD >> docs/team/$BN.md"
done