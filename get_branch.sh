#!/bin/bash

###########################################
#
# 获取所有的分支，导出为Json格式数据
#
###########################################

# 用法
if [ $# -ne 1 ];then
	echo -e "\e[1;31m Usage: $0 bundle_list! \e[0m"
	exit 1
fi

# 追加到json文件
appendToJson(){
	printf $1 >> $destFile
}


# 设置全局变量
rootDir=`pwd`
tempDir="tempGit"
tempBranchList="tempBranchList"
OLDIFS=$IFS
destFile=$rootDir/"bundle_branch_list.txt"

# 添加Git库列表，拉取全部分支
mkdir $tempDir
cd $tempDir
git init
while read line
do
	bundle=($line)
	git remote add $line
done < $rootDir/$1

# 获取全部分支数 保存至json文件
git fetch --all
git branch -a > $tempBranchList

echo -n "" > $destFile
appendToJson "{\n"
while read line
do
	IFS='/'
	bundle=($line)
	branch_bundle=${bundle[1]}
	branch_name=${bundle[2]}

	if [ -n "$old_bundle" ];then
		if [ "$old_bundle" = "$branch_bundle" ];then
			appendToJson ",\n    \"$branch_name\""
		else
			appendToJson "\n  ],\n"
			appendToJson "  \"$branch_bundle\":["
			appendToJson "\n    \"$branch_name\""
		fi
	else
		appendToJson "  \"$branch_bundle\":[\n"
		appendToJson "    \"$branch_name\""
	fi
	old_bundle=$branch_bundle

done < $tempBranchList
appendToJson "\n]}\n"

# 删除临时文件，恢复环境
IFS=$OLDIFS
cd $rootDir
rm -rf "$tempDir"

