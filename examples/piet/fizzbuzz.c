main()
{
  for( i = 1; i <= 100; i++ )
  {
    if( (!(i % 3)) && (!(i % 5)) )
    {
       fizzbuzz();
    }
    else
    {
      if (!(i%3)) { fizz(); }
      else
      {
        if (!(i%5)) { buzz(); } else { print( i ); }
      }
    }
  }
}

print(x) { __outn(x); __out(10); __out(13); }
fizz() { asm{ @"fizz\r\n" } }
buzz() { asm{ @"buzz\r\n" } }
fizzbuzz() { asm{ @"fizzbuzz\r\n" } }
