#!/bin/sh

#change CONF value to appropriate location
#CONF=put/location/of/new/postfix/virtual/configs/here
DEST=./tbp-postfix/config
cp $CONF/virtual $DEST/virtual
cp $CONF/vmailbox $DEST/vmailbox
cp $CONF/restrict_classes/houseleaders $DEST/restrict_classes/houseleaders
cp $CONF/restrict_classes/tbponly $DEST/restrict_classes/tbponly