// Dart
import 'dart:io';
// Custom
import 'package:coly/compiler/init.dart' as init;
import 'package:coly/token/token.dart';
import 'package:coly/token/token_type.dart';
import 'package:coly/reporter/reporter.dart';
import 'package:coly/interpreter/passthrough.dart' as passthrough;

Reporter report = Reporter();
Stopwatch stopwatch = Stopwatch()..start();

class Compiler {
  List<String> generate(List<Token> tokens) {
    List<String> code = [];
    // Init
    code.add(init.init);
    code.add("int main() {");
    code.add("// INIT\nstd::stack<value> stack;");
    // for (String arg in passthrough.args) {
    //   stack.add(Token("ARGS", TokenType.STRING, 0, 0, arg));
    // }

    // Iterate over tokens (interpret)
    for (int i = 0; i < tokens.length; i++) {
      Token token = tokens[i];
      TokenType type = token.type;
      int line = token.line;
      String file = token.file;
      dynamic value = token.value;

      void emptyPanic() {
        code.add("if (stack.empty()) panic(\"$value\", \"Empty stack\");");
      }

      void tooLittleItemsPanic(amountOfItems) {
        code.add(
            "if (stack.size() < $amountOfItems) panic(\"$value\", \"Insufficient stack values\");");
      }

      bool _isAtEnd() => i >= tokens.length - 1;

      if (type == TokenType.OPERATOR) {
        if (value == Tokens.PLUS) {
          code.add("// PLUS");
          code.add("""
          {
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v1.value) + std::stoi(v2.value));
                  stack.push(v);
                  }
          """);
        } else if (value == Tokens.MINUS) {
          code.add("// MINUS");
          code.add("""
        {
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) + std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.STAR) {
          code.add("// STAR");
          code.add("""
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v1.value) * std::stoi(v2.value));
                  stack.push(v);
          """);
        } else if (value == Tokens.SLASH) {
          code.add("// SLASH");
          code.add("""
          {
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) / std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.MODULO) {
          code.add("// MODULO");
          code.add("""
          {
          if (stack.size() < 2) panic("+", "Insufficient stack values");
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "integer" || v2.type != "integer") panic("+", "Invalid stack values");
                  value v;
                  v.type = "integer";
                  v.value = std::to_string(std::stoi(v2.value) % std::stoi(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_PLUS) {
          code.add("// FLOAT_PLUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("+.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v1.value) + std::stof(v2.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_MINUS) {
          code.add("// FLOAT_MINUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("-.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v2.value) - std::stof(v1.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_STAR) {
          code.add("// FLOAT_STAR");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("*.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v1.value) * std::stof(v2.value));
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.FLOAT_SLASH) {
          code.add("// FLOAT_MINUS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  if (v1.type != "float" || v2.type != "float") panic("/.", "Invalid stack values");
                  value v;
                  v.type = "float";
                  v.value = std::to_string(std::stof(v2.value) / std::stof(v1.value));
                  stack.push(v);
          }
          """);
        }
      } else if (type == TokenType.COMPARATOR) {
        if (value == Tokens.EQUAL_EQUAL) {
          code.add("// EQUAL_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = v1.value == v2.value ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.BANG_EQUAL) {
          code.add("// BANG_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = v1.value != v2.value ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.GREATER) {
          code.add("// GREATER");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) > std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.GREATER_EQUAL) {
          code.add("// GREATER_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) >= std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.LESS_EQUAL) {
          code.add("// LESS_EQUAL");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) <= std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        } else if (value == Tokens.LESS) {
          code.add("// LESS");
          tooLittleItemsPanic(2);
          code.add("""
          {
                  value v1 = stack.top();
                  stack.pop();
                  value v2 = stack.top();
                  stack.pop();
                  value v;
                  v.type = "boolean";
                  v.value = std::stoi(v2.value) < std::stoi(v1.value) ? "true" : "false";
                  stack.push(v);
          }
          """);
        }
      } else if (type == TokenType.KEYWORD) {
        // System
        if (value == "exit") {
          code.add("// EXIT");
          code.add("""
          if (stack.empty()) exit(0);
          value v = stack.top();
          stack.pop();
          if (v.type == "integer") exit(std::stoi(v.value)); else panic("exit", "Invalid stack value");
          """);
        } else if (value == "system") {
          // ifIsEmptyThrowError("system");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `system` failed. Item on stack must be a string.");
          //   _errorExit();
          // }
          // List<String> keywords = a.value.split(" ");
          // String cmd = keywords[0];
          // keywords.removeAt(0);
          // try {
          //   // make a shell command and print the result
          //   ProcessResult result = Process.runSync(cmd, keywords);
          //   _push(Token(file, TokenType.STRING, line, i, result.stdout));
          // } catch (e) {
          //   report.error(file, line,
          //       "Command `system` failed. Could not run command `${a.value}`.");
          //   _errorExit();
          // }
        } else if (value == "elapsed") {
          // _push(Token(file, TokenType.STRING, line, i,
          //     (stopwatch.elapsedMilliseconds / 1000).toString()));
        }
        // Input / Output
        else if (value == "out") {
          code.add("// OUT");
          emptyPanic();
          code.add("""
          std::cout << stack.top().value;
          stack.pop();
          """);
        } else if (value == "puts") {
          code.add("// PUTS");
          emptyPanic();
          code.add("""
          std::cout << stack.top().value << std::endl;
          stack.pop();
          """);
        } else if (value == "endl") {
          code.add("// ENDL");
          code.add("std::cout << std::endl;");
        } else if (value == "peek") {
          code.add("// PEEK");
          emptyPanic();
          code.add("std::cout << stack.top().value;");
        } else if (value == "input") {
          code.add("// INPUT");
          code.add("""
        {
          std::string input;
          std::cin >> input;
          value v;
          v.type = "string";
          v.value = input;
          stack.push(v);
        }
          """);
        }
        // Basic stack operations
        else if (value == "dump") {
          emptyPanic();
          code.add("// DUMP");
          code.add("stack.pop();");
        } else if (value == "dup") {
          emptyPanic();
          code.add("// DUP");
          code.add("stack.push(stack.top());");
        } else if (value == "clear") {
          code.add("// CLEAR");
          code.add("stack = std::stack<value>();");
        } else if (value == "swap") {
          code.add("// SWAP");
          tooLittleItemsPanic(2);
          code.add("""
          value v1 = stack.top();
          stack.pop();
          value v2 = stack.top();
          stack.pop();
          stack.push(v1);
          stack.push(v2);
          """);
        } else if (value == "over") {
          // ?
        } else if (value == "count") {
          code.add("// COUNT");
          code.add("stack.push(std::to_string(stack.size()));");
        } else if (value == "reverse") {
          code.add("// REVERSE");
          code.add("{\nstd::stack<value> temp;");
          code.add(
              "while (!stack.empty()) { temp.push(stack.top()); stack.pop(); }");
          code.add("stack = temp;\n}");
        }
        // Type conversion commands
        else if (value == "stoi") {
          code.add("// STOI");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("stoi", "Invalid stack value");
          v.type = "integer";
          try {
                  v.value = std::to_string(std::stoi(v.value));
          } catch (...) {
                  panic("stoi", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "stof") {
          code.add("// STOF");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "string") panic("stof", "Invalid stack value");
          v.type = "float";
          try {
                  v.value = std::to_string(std::stof(v.value));
          } catch (...) {
                  panic("stof", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "itof") {
          code.add("// ITOF");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "integer") panic("itof", "Invalid stack value");
          v.type = "float";
          v.value = std::to_string(std::stof(v.value));
          stack.push(v);
        }
          """);
        } else if (value == "ftoi") {
          code.add("// FTOI");
          emptyPanic();
          code.add("""
        {
          value v = stack.top();
          stack.pop();
          if (v.type != "float") panic("ftoi", "Invalid stack value");
          v.type = "integer";
          try {
                  v.value = std::to_string(floor(std::stof(v.value)));
          } catch (...) {
                  panic("stof", "Invalid stack value");
          }
          stack.push(v);
        }
          """);
        } else if (value == "atos") {
          code.add("// ATOS");
          emptyPanic();
          code.add("""
        {
          value v;
          v.type = "string";
          v.value = std::to_string(stack.top().value);
          stack.pop();
          stack.push(v);
        }
          """);
        }
        // Control flow
        else if (value == "if") {
          code.add("// IF");
          emptyPanic();
          code.add("if (stack.top().value == \"true\")");
        } else if (value == "set") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            exit(1);
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            exit(1);
          }
          code.add("// SET");
          code.add("${tokens[i].value}:");
        } else if (value == "jump") {
          if (_isAtEnd()) {
            report.error(
                file, line, "Command `set` is not followed by a name.");
            exit(1);
          }
          i++;
          if (tokens[i].type != TokenType.KEYWORD) {
            report.error(file, line,
                "Command `set` is not followed by a name. Expected identifier.");
            exit(1);
          }
          code.add("// JUMP");
          code.add("goto ${tokens[i].value};");
        } else if (value == "free") {
          // No operation in C++
        }
        // String
        else if (value == "concat") {
          // ifTooLittleItemsThrowError(2, "concat");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `concat` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(file, TokenType.STRING, line, i, b.value + a.value));
        } else if (value == "trim") {
          // ifIsEmptyThrowError("trim");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `trim` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(file, TokenType.STRING, line, i, a.value.trim()));
        } else if (value == "split") {
          // ifTooLittleItemsThrowError(2, "split");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `split` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // for (String s in b.value.split(a.value)) {
          //   _push(Token(file, TokenType.STRING, line, i, s));
          // }
        } else if (value == "revsplit") {
          // ifTooLittleItemsThrowError(2, "revsplit");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `split` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }

          // List<String> split = b.value.split(a.value);
          // for (int i = split.length - 1; i >= 0; i--) {
          //   _push(Token(file, TokenType.STRING, line, i, split[i]));
          // }
        } else if (value == "length") {
          // ifIsEmptyThrowError("length");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `length` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(file, TokenType.INTEGER, line, i, a.value.length));
        } else if (value == "replace") {
          // ifTooLittleItemsThrowError(3, "replace");
          // Token a = _pop();
          // Token b = _pop();
          // Token c = _pop();
          // if (a.type != TokenType.STRING ||
          //     b.type != TokenType.STRING ||
          //     c.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `replace` failed. All items on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(file, TokenType.STRING, line, i,
          // c.value.replaceAll(b.value, a.value)));
        } else if (value == "contains") {
          // ifTooLittleItemsThrowError(2, "contains");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `contains` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(
          //     file, TokenType.BOOLEAN, line, i, b.value.contains(a.value)));
        } else if (value == "startswith") {
          // ifTooLittleItemsThrowError(2, "startswith");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `startswith` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(
          //     file, TokenType.BOOLEAN, line, i, b.value.startsWith(a.value)));
        } else if (value == "endswith") {
          // ifTooLittleItemsThrowError(2, "endswith");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `endswith` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(
          //     file, TokenType.BOOLEAN, line, i, b.value.endsWith(a.value)));
        }
        // FileStream
        else if (value == "fRead") {
          // ifIsEmptyThrowError("fRead");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fRead` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // try {
          //   _push(Token(file, TokenType.STRING, line, i,
          //       File(a.value).readAsStringSync()));
          // } catch (e) {
          //   report.error(file, line,
          //       "Command `fRead` failed. File does not exist or is not readable.");
          //   _errorExit();
          // }
        } else if (value == "fWrite") {
          // ifTooLittleItemsThrowError(2, "fWrite");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fWrite` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // try {
          //   File(a.value).writeAsStringSync(b.value);
          // } catch (e) {
          //   report.error(file, line,
          //       "Command `fWrite` failed. File does not exist or is not writable.");
          //   _errorExit();
          // }
        } else if (value == "fAppend") {
          // ifTooLittleItemsThrowError(2, "fAppend");
          // Token a = _pop();
          // Token b = _pop();
          // if (a.type != TokenType.STRING || b.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fAppend` failed. Both items on stack must be of type string.");
          //   _errorExit();
          // }
          // try {
          //   File(a.value).writeAsStringSync(b.value, mode: FileMode.append);
          // } catch (e) {
          //   report.error(file, line,
          //       "Command `fAppend` failed. File does not exist or is not writable.");
          //   _errorExit();
          // }
        } else if (value == "fDelete") {
          // ifIsEmptyThrowError("fDelete");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fDelete` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // try {
          //   File(a.value).deleteSync();
          // } catch (e) {
          //   report.error(file, line,
          //       "Command `fDelete` failed. File does not exist or is not writable.");
          //   _errorExit();
          // }
        } else if (value == "fExists") {
          // ifIsEmptyThrowError("fExists");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fExists` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // _push(Token(
          //     file, TokenType.BOOLEAN, line, i, File(a.value).existsSync()));
        } else if (value == "fCreate") {
          // ifIsEmptyThrowError("fCreate");
          // Token a = _pop();
          // if (a.type != TokenType.STRING) {
          //   report.error(file, line,
          //       "Command `fCreate` failed. Item on stack must be of type string.");
          //   _errorExit();
          // }
          // try {
          //   File(a.value).createSync();
          // } catch (e) {
          //   report.error(file, line, "Command `fCreate` failed.");
          //   _errorExit();
          // }
        }
        // Unknown keyword
        else {
          report.error(file, line, "Unknown command `$value`.");
          exit(1);
        }
      } else if (type == TokenType.CHARACTER) {
        if (value == Tokens.LEFT_BRACE) code.add('{');
        if (value == Tokens.RIGHT_BRACE) code.add('}');
      } else if (type == TokenType.LANGUAGE) {
        if (!_isAtEnd()) {
          report.error(file, line, "Unexpected end of file.");
        }
      } else {
        String? stype;
        if (type == TokenType.STRING) stype = "string";
        if (type == TokenType.INTEGER) stype = "integer";
        if (type == TokenType.FLOAT) stype = "float";
        if (type == TokenType.BOOLEAN) stype = "boolean";

        code.add("// PUSH");
        code.add("""
          {
              value v;
              v.type = "$stype";
              v.value = "$value";
              stack.push(v);
          }

          """);
      }
    }
    code.add("// END\nreturn 0;\n}");

    File("test.cpp").writeAsStringSync(code.join('\n'));
    return code;
  }
}
