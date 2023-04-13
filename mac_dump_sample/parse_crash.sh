#!/bin/bash
function checkFileIfNotExit(){
	if [ ! -e $1 ];then
		echo $1"不存在，请确认该文件存在后再试！"
		exit
	fi
}
#替换成你自己的应用名字
APP_NAME="TMSDKFramework"
APP_DYSM_FILE=$APP_NAME".framework.dSYM"
APP_SYM_FILE=$APP_NAME".sym"

checkFileIfNotExit $APP_DYSM_FILE
# if [ ! -e $APP_DYSM_FILE ];then
# 	echo $APP_DYSM_FILE"不存在，请确认该文件存在后再试！"
# 	exit
# fi

CMD_DUMP_SYM_FILE="./dump_syms"
CMD_DUMP_STACK_FILE="./minidump_stackwalk"
PARSE_RESULT_SUFFIX="_parseresult.txt"

checkFileIfNotExit $CMD_DUMP_SYM_FILE
checkFileIfNotExit $CMD_DUMP_STACK_FILE

echo “/*********** dSYM文件转sym文件开始执行，可能需要等待几十秒到几分钟..... ************/”
trans=`$CMD_DUMP_SYM_FILE $APP_DYSM_FILE > $APP_SYM_FILE`
#./dump_syms -a arm64 TMSDKFramework.framework.dSYM > TMSDKFrameworkArm64.sym
# echo "result=$?"
result=$?
echo "result=$result"
if [ $result -ne 0 ];then
	# echo $trans
	echo "执行"$CMD_DUMP_SYM_FILE"报错：dSYM文件转sym文件失败，具体信息请看上面的错误信息，请根据错误信息解决问题后再试！"
	exit
fi
echo “/*********** dSYM文件转sym文件结束 ************/”
head1=`head -n1 $APP_SYM_FILE`
#取head1中被空格分割的第四个参数
symbol_num=`echo $head1 | awk '{print $4}'`
echo $symbol_num

symbols_dir="./symbols/"$APP_NAME"/"$symbol_num
mkdir -p $symbols_dir
mv $APP_SYM_FILE $symbols_dir


for file in `ls`
do
	if echo "$file" | grep -q -E '\.dmp$'
	then
		fileName=${file/.dmp/}
		$CMD_DUMP_STACK_FILE $file ./symbols > $fileName$PARSE_RESULT_SUFFIX
	fi
done

echo "/******* dmp文档崩溃信息解析结果保存在下面文件中：*******/"
for file in `ls`
do
	if echo "$file" | grep -q -E '\.dmp$'
	then
		fileName=${file/.dmp/}
		echo $fileName$PARSE_RESULT_SUFFIX
	fi
done


