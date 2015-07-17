#!/bin/bash

# requirements
# - RVM
# - metrics_fu gem

USERDIR='/home/vovan'
APPDIR="$USERDIR/rails_projects/app"
OUTDIR="/data/data/metric_fu"

# create project backup
#cd $APPDIR/..
#tar cfz app.tar.gz app
cd $APPDIR

# activate rvm
source $USERDIR/.rvm/scripts/rvm
source $USERDIR/.bashrc

# save id's of all commits
git log --pretty=tformat:%h > /tmp/commits.txt

# process all commits in revers order (starting newest)
PREVDATE='0'
for commit in `cat /tmp/commits.txt`; do
	echo '----------------------'
    echo "the next commit is $commit"
    git -c core.quotepath=false checkout $commit
    # get date of commit
    timestamp=`git show -s --format=%ct $commit`
    DATE=`date -d @$timestamp +%Y%m%d`
    echo "PROCESSING: $OUTDIR/_data/$DATE.yml"
    if [ ! -f $OUTDIR/_data/$DATE.yml ]; then

        # skip commit with the same date
        if [ "$DATE" != "$PREVDATE" ]
        then

            # set current date (very bad! Need force metric_fu to use cpecific date)
            date -s @$timestamp
            date
            metric_fu
            #pgrep chrome | xargs kill

            cd $APPDIR/..
            rm -r $APPDIR
            tar xfz app.tar.gz
            # убрать строку

            mkdir $APPDIR/tmp
            unlink $APPDIR/tmp/metric_fu
            ln -s $OUTDIR $APPDIR/tmp/metric_fu
            cd $APPDIR

        fi
    else
        echo "EXISTS: $OUTDIR/_data/$DATE.yml"        
    fi

    PREVDATE=$DATE
done