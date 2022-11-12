#!/bin/bash

set -eu

MODE=$1
PARAMS=${@:2:($#-1)}


echo "------"
echo "$@"
echo "TYPE: $MODE"
echo "PARAMS: $PARAMS"
# echo "VERBOSE: $VERBOSE"
echo "------"


# 起動
if  [ "${MODE}" = "MMVC" ] ; then
    cd /voice-changer-internal/voice-change-service

    if [[ -e /resources/setting.json ]]; then
        echo "指定された設定(setting.json)を使用します。"
        cp /resources/setting.json ../frontend/dist/assets/setting.json
    else
        echo "デフォルトの設定(setting.json)を使用します。"
        cp ../frontend/dist/assets/setting_mmvc.json ../frontend/dist/assets/setting.json
    fi

    find /resources/ -type f -name "config.json" | xargs -I{} sh -c 'echo "config.jsonをコピーします。" && cp {} ./'
    find /resources/ -type f -name "*.pth"       | xargs -I{} sh -c 'echo "`basename {}`をコピーします。" && cp {} ./'

    echo "MMVCを起動します"
    python3 MMVCServerSIO.py -t MMVC $PARAMS #2>stderr.txt

elif [ "${MODE}" = "TRAIN" ] ; then
    cd /voice-changer-internal/voice-change-service
    python3 -m tensorboard.main --logdir /MMVC_Trainer/logs --port 6006 --host 0.0.0.0 &
    python3 MMVCServerSIO.py -t TRAIN $PARAMS
fi

