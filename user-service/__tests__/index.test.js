const hello = require('../index');

test('hello function returns correct string', () => {
  expect(hello()).toBe('Hello from user-service!');
});
