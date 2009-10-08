use v6;

grammar Shrdlu::Language {
    rule TOP { ^ <order> $ }

    rule order { <pick_up> <noun_phrase> '.'? }

    rule pick_up { pick up | grasp }

    rule noun_phrase { <article> <attribute>* <noun> }

    rule article { a | the }
    rule attribute { <color> | <size> }
    rule color { red }
    rule size { big }
    rule noun { block | pyramid }
}

class Shrdlu::Object {
    has $.size;
    has $.shape;
    has $.color;

    # RAKUDO: Possibly do this one better
    method new($size, $shape, $color) {
        self.bless(*, :$size, :$shape, :$color);
    }
}

class Shrdlu {
    has @!blocks;
    has @.reply;

    submethod BUILD() {
        given Shrdlu::Object {
            @!blocks =
                .new( |<big red block> ),
                .new( |<big red pyramid> ),
                .new( |<small green pyramid> ),
            ;
        }
    }

    method tell(Str $sentence) {
        if Shrdlu::Language.parse($sentence.lc) {
            my @possible-objects;
            my ($desired-shape, $desired-size, $desired-color) = *, *, *;
            given $<order><noun_phrase> {
                $desired-shape = ~.<noun>;
                if .<attribute> {
                    for .<attribute>.list {
                        if .<color> {
                            $desired-color = .Str;
                        }
                        elsif .<size> {
                            $desired-size = .Str;
                        }
                        else {
                            die "Unknown type of attribute.";
                        }
                    }
                }
            }
            @possible-objects = grep {
                all(                .shape,         .size,         .color
                     >>~~<< $desired-shape, $desired-size, $desired-color )
            }, @!blocks;
            @!reply = @possible-objects == 1
                        ?? 'OK.'
                        !! "I don't understand which $desired-shape you mean.";
        }
        else {
            @!reply = 'I don\'t understand';
        }
    }
}
