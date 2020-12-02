# Utiliizer

Not finished, trying hands on a utility library in perl.
Method documentation in code.
## Table

Supports markdown and rsf tables as well as custom margin and row numbers.
Example:
```perl
# EXAMPLE

my @header = ("__Zentriert", "_Rechts", "Links/Normal", "*Cool*");
my @entry1 = (0, 1, 2, 434);
my @entry2 = (2, 232434,34, 2);
my @entry3 = (24, 2, 2, 4334);
my @data;
push @data, \@entry1, \@entry2, \@entry3;

my $tb = Table->new(\@header, \@data);
$tb->print(0, 1);
```

Output:
| Zentriert | Rechts | Links/Normal | *Cool* |
|:---------:|-------:|--------------|--------|
| 0         | 1      | 2            | 434    |
| 2         | 232434 | 34           | 2      |
| 24        | 2      | 2            | 4334   |
