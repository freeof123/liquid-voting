import subprocess
import os
import sys

current_file = os.path.abspath(__file__)
current_dir = os.path.dirname(current_file)
test_dir = os.path.join(current_dir, "test")
output_dir = os.path.join(current_dir, "output")

def execute_cmd(cmd):
    print(cmd)
    p = subprocess.Popen(cmd, shell=True, stdout = subprocess.PIPE)
    return p.stdout.read()


def gen_file(fp, target_fp, number):
    fp = os.path.join(test_dir, fp);
    target_fp = os.path.join(test_dir, target_fp);
    f1 = open(fp, 'r');
    f2 = open(target_fp, 'w')
    c = f1.read()
    c = c.replace('{{VCOUNT_NUMBER}}', str(number))
    f2.write(c);
    f1.close();
    f2.close();

def execute_eval(number):
    fp = os.path.join(output_dir, str(number))
    if os.path.exists(fp):
        return fp
    gen_file("eval_chain_head_vote.js.template", "eval_chain_head_vote.js", number);
    gen_file("eval_chain_root_vote.js.template", "eval_chain_root_vote.js", number);

    cmd_tmp = "truffle test  ./test/{} --network ganache"
    t1 = execute_cmd(cmd_tmp.format("eval_chain_head_vote.js"))
    t2 = execute_cmd(cmd_tmp.format("eval_chain_root_vote.js"))
    f = open(fp, 'w');
    f.write(t1);
    f.write(t2);
    f.close();
    return fp

def do_all_eval():
    numbers = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000]
    for n in numbers:
        print('eval {}...'.format(n))
        execute_eval(n)


if __name__ == '__main__':
    do_all_eval()
