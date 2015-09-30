//: Playground - noun: a place where people can play

import UIKit

var str = "5701 Phelps luck dr"

let result = str.characters.split { $0 == " " }.map(String.init)
var address = ""
for var i = 0 ; i < result.count; i++ {
    address += result[i] + "%20"
}

print(address)