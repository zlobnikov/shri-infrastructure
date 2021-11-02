'use strict';

const operations = {
  '+': (a, b) => a + b,
  '-': (a, b) => a - b,
  '*': (a, b) => a * b,
  '/': (a, b) => a / b,
  '%': (a, b) => a % b,
  '//': (a, b) => (a - a % b) / b,
};

function getOperand() {
  const enterMessage = 'Enter any number';
  const errorMessage = 'The input is incorrect';

  let number = prompt(enterMessage, 0);

  while(isNaN(number) && number !== null) {
    alert(errorMessage);
    number = prompt(enterMessage, 0);
  }

  return number;
}

function getOperator() {
  const enterMessage = 'Enter math operator';
  const errorMessage = 'Unknown operator';

  let operator = prompt(enterMessage, '+');

  while (!operations[operator] && operator !== null) {
    alert(errorMessage);
    operator = prompt(enterMessage, '+');
  }

  return operator;
}

function calc() {
  let a = getOperand();
  if (a === null) return null;
  else a = Number(a);

  const operator = getOperator();
  if (operator === null) return null;

  let b = getOperand();
  if (b === null) return null;
  else b = Number(b);

  return operations[operator](a, b);
}

const result = calc();

if (result !== null) alert(`Your result: ${result}`);
else alert('Operation is canceled');
