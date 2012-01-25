should = require 'should'
fuzzy  = require '../'

describe "fuzzy-filter", ->
  describe "basic usage", ->
    items = fuzzy "cs", [
      "cheese"
      "crackers"
      "pirate attack" ]
    
    it "returns an Array", ->
      items.should.be.an.instanceof Array
    
    it "filters the items", ->
      items.should.eql ["cheese", "crackers"]
  
  describe "ignorecase", ->
    describe "is true by default", ->
      describe "when the pattern has mismatched caps", ->
        items = fuzzy "CS", [
          "cheese"
          "crackers"
          "pirate attack" ]
        
        it "filters the items", ->
          items.should.eql ["cheese", "crackers"]
      
      describe "when the items have mismatched caps", ->
        items = fuzzy "cs", [
          "CHEESE"
          "crackers"
          "pirate attack"
        ], {pre: "<b>", post: "</b>"}
        
        it "filters the items", ->
          items.should.eql ["<b>C</b>HEE<b>S</b>E", "<b>c</b>racker<b>s</b>"]
    
    describe "when false", ->
      items = fuzzy "CS", [
        "cheese"
        "crackers"
        "pirate attack"
      ], {ignorecase: false}
      
      it "filters the items", ->
        items.should.eql []
  
  describe "ignorespace", ->
    describe "is true by default", ->
      items = fuzzy "c s", [
        "cheese"
        "crackers"
        "pirate attack" ]
      
      it "filters the items", ->
        items.should.eql ["cheese", "crackers"]
    
    describe "when false", ->
      items = fuzzy "c s", [
        "cheese"
        "crackers"
        "pirate attack"
      ], {ignorespace: false}
      
      it "filters the items", ->
        items.should.eql []
  
  
  describe "limit", ->
    items = fuzzy "1", [
      "123"
      "abc"
      "123"
      "123"
    ], {limit: 2}
    it "limits the number of items matched", ->
      items.length.should.eql 2
  
  
  describe "when nothing matches", ->
    items = fuzzy "bla", [
      "cheese"
      "pickles"
      "crackers"
      "pirate attack" ]
    
    it "returns []", ->
      items.should.eql []
  
  describe "beginning-of-text match", ->
    items = fuzzy "cs", [
      "cheese"
      "crackers"
      "pirate attack"
      "cs!!" ]
    
    it "puts the beginning-of-text match first", ->
      items.should.eql ["cs!!", "cheese", "crackers"]
  
  describe "with pre/post options", ->
    items = fuzzy "cs", [
      "cheese"
      "crackers"
      "pirate attack"
      "cs!!"
    ] , {pre:  "<b>", post: "</b>"}
    it "bolds the items", ->
      items.should.eql ["<b>cs</b>!!"
        "<b>c</b>hee<b>s</b>e"
        "<b>c</b>racker<b>s</b>"]
  
  describe "with a separator", ->
    describe "when the separator is not in the pattern", ->
      it "matches against the last segment", ->
        items = fuzzy "cs", [
          "cookies"
          "cheese/pie"
          "fried/cheese"
          "cheese/cookies"
        ], {
          pre:       "<b>"
          post:      "</b>"
          separator: "/"
        }
        items.should.eql [
          "<b>c</b>ookie<b>s</b>"
          "fried/<b>c</b>hee<b>s</b>e"
          "cheese/<b>c</b>ookie<b>s</b>" ]
      
      it "matches against only the last segment", ->
        items = fuzzy "foo", [
          "foo/bar"
          "bar/foo"
        ], {separator: "/"}
        items.should.eql ["bar/foo"]
    
    
    describe "when the pattern contains the separator", ->
      items = fuzzy "cs/", [
        "cookies"
        "cheese/pie"
        "fried/cheese"
        "cheese/cookies"
      ], {
        pre:       "<b>"
        post:      "</b>"
        separator: "/"
      }
      it "matches the first part of the string", ->
        items.should.eql [
          "<b>c</b>hee<b>s</b>e/pie"
          "<b>c</b>hee<b>s</b>e/cookies" ]
    
    describe "and text before and after", ->
      items = fuzzy "cs/p", [
        "cookies"
        "cheese/pie"
        "fried/cheese"
        "cheese/cookies"
      ], {
        pre:       "<b>"
        post:      "</b>"
        separator: "/"
      }
      it "filters both parts", ->
        items.should.eql ["<b>c</b>hee<b>s</b>e/<b>p</b>ie"]
    
    describe "when `separate` is true", ->
      describe "basic match", ->
        items = fuzzy "cs", [
          "a/cheese"
          "b/crackers"
          "c/pirate attack"
        ], {separate: true, separator: "/"}
        
        it "filters the items", ->
          items.should.eql [["a", "cheese"], ["b", "crackers"]]
      
      describe "with pattern text before and after the separator", ->
        items = fuzzy "cs/p", [
          "cookies"
          "cheese/pie"
          "fried/cheese"
          "cheese/cookies"
        ], {
          pre:       "<b>"
          post:      "</b>"
          separator: "/"
          separate:  true
        }
        
        it "is an Array of Array of String", ->
          items.should.be.an.instanceof Array
          items[0].should.be.an.instanceof Array
          items[0][0].should.be.a "string"
        
        it "filters both parts", ->
          items.should.eql [ ["<b>c</b>hee<b>s</b>e", "<b>p</b>ie"] ]
      
      describe "beginning-of-text match", ->
        items = fuzzy "cs", [
          "cheese"
          "crackers"
          "pirate attack"
          "cs!!"
        ], {separate: true, separator: "/"}
        
        it "puts the beginning-of-text match first", ->
          items.should.eql [
            ["", "cs!!"]
            ["", "cheese"]
            ["", "crackers"] ]
      
      describe "when `separator` is not passed", ->
        it "throws", ->
          should.throws ->
            items = fuzzy "cs", ["cheese"], {separate: true}

