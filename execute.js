var path = process.argv[2];

var fs =require('fs');
var asmArr = fs.readFileSync(path).toString().split('\r\n');

function split(str){
    // remove begin white space
    str = str.replace(/\t/g,"");
    while(str[0] == " "){
        str =str.substring(1);
    }
    var index = str.indexOf(' ');
    if(index != -1){
        var operator = str.substring(0,index);
        var remain = str.substring(index+1)
        return [operator, remain];
    }
    return [str];
}


var funcTable = {};
var execStack = [];
var resultObj = {};
var jmpTable = {}

for(var i=0;i< asmArr.length;i++){
    var item = asmArr[i];
        if(item[0] == '_'){
        jmpTable[item] = i;
    }
}

function executeAsm(asmArr,execStack,resultObj,begin,end){
 for(var i=begin;i < end;i++){
    var item = asmArr[i];
    var tmp = split(item);
    switch(tmp[0]){
        case "push":
            var variable = resultObj[tmp[1]];
            if(variable && variable.value !=undefined ){
            execStack.unshift(variable.value);
                            }else{
            console.log("Variable undefined");
            process.exit();
                            }
            break;
        case "push_num" :
            var value = parseFloat(tmp[1]);
            execStack.unshift(value);  
            break;
        case "push_str" :
            var str = tmp[1].substring(1,tmp[1].length-1);
            execStack.unshift(str);  
            break;
        case "int":
            if(resultObj[tmp[1]] != undefined){
            console.log("error already defined!");
            return;
                            }
            resultObj[tmp[1]] = {type:"number"};
            break;
        case "pop":
            var variable = resultObj[tmp[1]];
            if(variable == undefined){
                console.log("cannot set value before declartion");
                return;
            }
            var popVal = execStack.shift();
            variable.value = popVal;
            break;
        case "add":
        case "mul":
        case "sub":
        case "div":
        case "cmpgt":
        case "cmplt":
        case "cmpge":
        case "cmple":
        case "cmpne":
        case "cmpeq":
            var v1 = execStack.shift();
            var v2 = execStack.shift();
            var result = eval_binary_expression(v1,v2,tmp[0]);
            execStack.unshift(result);
            break;
        case "print":
            var v1 = execStack.shift();
            console.log(v1);
            break;
        case "call":
            var funcName = tmp[1];
            var funcObj = funcTable[funcName];

            if(!funcObj){
            console.log("function undefined!");
            process.exit();
                            }
            var args = funcObj.args;
            var localResultObj = {};
            var localStack = [];
            for(var j=args.length-1 ;j>=0;j--){
                var arg = args[j];
                var argValue = execStack.shift();
                var type = typeof argValue;
                localResultObj[arg] = {value:argValue,type:type};
            }
            var result = executeAsm(asmArr,localStack,localResultObj,funcObj.begin,funcObj.end);
            execStack.unshift(result);
            continue;
        case "ret":
            return execStack.shift();
        case "FUNC":
            var funcName = tmp[1].substring(1);
            var args = split(asmArr[i+1])[1].split(",");
            var obj = {
            begin:i+2, // skip FUNC and args
            args:args
                            }
            while(asmArr[i] !== "ENDFUNC"){
            i++;
                            }
            obj.end = i;
            funcTable[funcName]=obj;
            break;
        case "jz":
            var v1 = execStack.shift();
            if(!v1){
            var label = tmp[1];
            i = jmpTable[label];
                            }
            break;
        case "jmp":
            var label = tmp[1];
            i = jmpTable[label];
            break;

        case "array":
            var name = tmp[1];
            var size = tmp[2];
            if(resultObj[name]){
                console.log(name +" already defined.");
                process.exit();
            }
            var arr = new Array(size);
            resultObj[name] = {type:"array",size:size,value: arr};
            break;

        case "callArray":
            var name = tmp[1];
            if(!resultObj[name] || resultObj[name].type !== "array"){
                console.log("arr does not exist!");
                process.exit();
            }
            var index = execStack.shift();
            if(index > resultObj[name].size ){
                console.log("arr index overflow!");
                process.exit();
            }
            var value = resultObj[name].value[index];
            if(value == undefined){
                console.log("value not defined");
                process.exit();
            }
            execStack.unshift(value);
            break;
                            
        }
    }
}

executeAsm(asmArr,execStack,resultObj,0,asmArr.length);

function eval_binary_expression(v1,v2,operator){
 switch (operator){
    case "add":
        return v2+v1;
    case "sub":
        return v2-v1;
    case "mul":
        return v2*v1;
    case "div":
        return v2/v1;
    case "cmpgt":
        return v2>v1;
    case "cmplt":
        return v2<v1;
    case "cmpge":
        return v2>=v1;
    case "cmple":
        return v2<=v1;
    case "cmpeq":
        return v2===v1;
    case "cmpne":
        return v2!==v1;
    }
}
