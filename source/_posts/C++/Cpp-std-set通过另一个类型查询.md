---
title: C++ std::set通过另一个类型查询
date: 2022-10-04 14:44:21
tags:
---

在Comparator里加上`typedef std::true_type is_transparent;`。原因主要是为了保持前向兼容。

```cpp
#include <cassert>
#include <set>

class Point {
    public:
        Point(int x, int y) : x(x), y(y) {}
        int x;
        int y;
};

struct PointCmpY {
    // https://stackoverflow.com/questions/20317413/what-are-transparent-comparators
    typedef std::true_type is_transparent;
    bool operator()(const Point& lhs, int rhs) const {
        return lhs.y < rhs;
    }
    bool operator()(int lhs, const Point& rhs) const {
        return lhs < rhs.y;
    }
    bool operator()(const Point& lhs, const Point& rhs) const {
        return lhs.y < rhs.y;
    }
};

int main() {
    std::set<Point, PointCmpY> s;
    s.insert(Point(1, -1));
    s.insert(Point(2, -2));
    s.insert(Point(0,  0));
    s.insert(Point(3, -3));
    assert(s.find(0)->x == 0);
    assert(s.find(-1)->x == 1);
    assert(s.find(-2)->x == 2);
    assert(s.find(-3)->x == 3);
    assert(s.find(Point(1234, -1))->x == 1);
}
```

来源：

<https://stackoverflow.com/questions/13827973/how-to-make-a-c-map-container-where-the-key-is-part-of-the-value/41624995#41624995>

<https://stackoverflow.com/questions/20317413/what-are-transparent-comparators>
