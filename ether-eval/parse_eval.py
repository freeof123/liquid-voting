import subprocess
import os
import sys
import pgf

current_file = os.path.abspath(__file__)
current_dir = os.path.dirname(current_file)
test_dir = os.path.join(current_dir, "test")

output_dir = os.path.join(current_dir, "output")
final_dir = os.path.join(current_dir, "final")

def get_result_from_fp(fp):
    f = open(fp, 'r')
    ret = {}

    ret["simple-head"] = 0;
    ret["liquid-head"] = 0;
    ret["simple-root"] = 0;
    ret["liquid-root"] = 0;
    for line in f.readlines():
        if line.startswith("head vote simple vote gas:"):
            ns = [int(i) for i in line.split() if i.isdigit()]
            ret["simple-head"] = ns[0];
        if line.startswith("head vote liquid vote gas:"):
            ns = [int(i) for i in line.split() if i.isdigit()]
            ret["liquid-head"] = ns[0];
        if line.startswith("root vote simple vote gas:"):
            ns = [int(i) for i in line.split() if i.isdigit()]
            ret["simple-root"] = ns[0];
        if line.startswith("root vote liquid vote gas:"):
            ns = [int(i) for i in line.split() if i.isdigit()]
            ret["liquid-root"] = ns[0];
    f.close()
    return ret;

def do_all_eval():
    numbers = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
    ret = {}
    xk = []
    for number in numbers:
        fp = os.path.join(output_dir, str(number))
        if os.path.exists(fp):
            ret[number] = get_result_from_fp(fp);
            xk.append(number)

    print ret
    p = pgf.Plot()
    p.addplot(xk , lambda x:x, lambda x:ret[x]["simple-head"], legend="simple-head")
    p.addplot(xk , lambda x:x, lambda x:ret[x]["liquid-head"], legend="liquid-head")
    s = p.dump()
    s = pgf.make_standalone(s);
    open(os.path.join(final_dir, "head.tex"), 'w').write(s);

    p1 = pgf.Plot()
    p1.addplot(xk , lambda x:x, lambda x:ret[x]["simple-root"], legend="simple-root")
    p1.addplot(xk , lambda x:x, lambda x:ret[x]["liquid-root"], legend="liquid-root")
    s = p1.dump()
    s = pgf.make_standalone(s);
    open(os.path.join(final_dir, "root.tex"), 'w').write(s);
    return ret;


if __name__ == '__main__':
    do_all_eval()
