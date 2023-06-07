#!/bin/python3

import math
import os
import random
import re
import sys
from typing import Dict, Optional, Tuple, Any



Action = str

class State:
    def __init__(self, authorzized=False):
        self.authorized = authorzized
        
    def __str__(self):
        if self.authorized:
            return "authorized"
        else:
            return "unauthorized"
    
AUTHORIZED_STATE = State(True)
UNAUTHORIZED_STATE = State(False)

'''
logout - The request is successful and the user's new state is unauthorized. There is no return value.
deposit <amount> - The request is successful and the amount is added to the account balance.
withdraw <amount> -
If the balance in the account is at least as much as the requested amount, the request is successful. The amount is deducted from the balance.
Otherwise, the request is unsuccessful and the balance is unchanged.
balance - return the balance
'''

def check_login(param, password, balance):
    if param == password:
        return True, balance, None
    else:
        return False, balance, None

def check_logout(param, password, balance):
    return True, balance, None

def check_deposit(depositAmount, password, balance):
    if (depositAmount > 0):
        return True, balance + depositAmount, None
    else:
        return False, balance, None

def check_withdraw(withdrawAmount, password, balance):
    if (withdrawAmount <= balance) and (withdrawAmount > 0):
        return True, balance - withdrawAmount, None
    else:
        return False, balance, None

def check_balance(param, password, balance):
    return True, balance, balance

# Implement the transition_table here
transition_table = {
    AUTHORIZED_STATE: [("logout", check_logout, UNAUTHORIZED_STATE),
                       ("deposit", check_deposit, AUTHORIZED_STATE),
                       ("withdraw", check_withdraw, AUTHORIZED_STATE),
                       ("balance", check_balance, AUTHORIZED_STATE)],
    UNAUTHORIZED_STATE: [("login", check_login, AUTHORIZED_STATE)],
}

# Implement the init_state here
init_state = UNAUTHORIZED_STATE

# Look for the implementation of the ATM class in the below Tail section

if __name__ == "__main__":
    class ATM:
        def __init__(self, init_state: State, init_balance: int, password: str, transition_table: Dict):
            self.state = init_state
            self._balance = init_balance
            self._password = password
            self._transition_table = transition_table

        def next(self, action: Action, param: Optional) -> Tuple[bool, Optional[Any]]:
            try:
                print(self._transition_table)
                for transition_action, check, next_state in self._transition_table[self.state]:
                    if action == transition_action:
                        passed, new_balance, res = check(param, self._password, self._balance)
                        if passed:
                            self._balance = new_balance
                            self.state = next_state
                            return True, res
            except KeyError:
                print("ERROR")
                import traceback
                traceback.print_exc()
                pass
            return False, None


    if __name__ == "__main__":
        password = input()
        init_balance = int(input())
        atm = ATM(init_state, init_balance, password, transition_table)
        q = int(input())
        for _ in range(q):
            action_input = input().split()
            action_name = action_input[0]
            try:
                action_param = action_input[1]
                if action_name in ["deposit", "withdraw"]:
                    action_param = int(action_param)
            except IndexError:
                action_param = None
            success, res = atm.next(action_name, action_param)
            if res is not None:
                print(f"Success={success} {atm.state} {res}\n")
            else:
                print(f"Success={success} {atm.state}\n")


# hacker
# 10
# 2
# login foo
# login hacker
