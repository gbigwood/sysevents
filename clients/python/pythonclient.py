import threading
import json
import requests
from uuid import uuid4


# TODO extensions:
# * Why not just use a global stack? -- because we want thread specific tracing
# * How to inject stack across thread boundaries? -- e.g. spawner of thread pool
# * Interplay with co-routines?


THREAD_LOCAL = threading.local()  # 🙈 Each call gets a view so must be global or passed in 🙈 


def _find_parent_id(thread_locals):
    if len(thread_locals.frame_stack):
        return thread_locals.frame_stack[-1]
    else:
        return None


def _save_current_frame(thread_locals):
    curr_id = str(uuid4())
    # Can't add attributes to frames cause they are wrappers for C struct (interpreter
    # implementation specific)
    thread_locals.frame_stack.append(curr_id)
    return curr_id


def _construct_frame_stack(thread_locals):
    # You're not supposed to recurse in python so stack per tracked call should be fine :)
    frame_stack = getattr(thread_locals, 'frame_stack', None)
    if not frame_stack:
        thread_locals.frame_stack = []


def _pop_stack(thread_locals):
    thread_locals.frame_stack.pop()


def _save_on_server(parent_id, current_id, wrapped_func, info):
    # curl -H 'Content-Type: application/json' -X PUT -d "{\"parent_id\": \"$firstuuid\", \"type\": \"get user\"}" http://localhost:4000/link/$seconduuid
    try:
        response = requests.put(
                url="http://localhost:4000/link/{}".format(current_id),
                json={'parent_id': parent_id, 'type': info},
                headers={'Content-Type': 'application/json'})
        assert response.status_code == 200
        print("Event: {!s:36} {:36} {:36} {!s}".format(parent_id, current_id, wrapped_func.__name__, info))
    except Exception as e:
        print("ruh roh", e)


def trace(info):
    def decorator(func):
        def func_wrapper(*args, **kwargs):
            _construct_frame_stack(THREAD_LOCAL)
            parent_id = _find_parent_id(THREAD_LOCAL)
            current_id = _save_current_frame(THREAD_LOCAL)
            _save_on_server(parent_id, current_id, func, info)
            result = func(*args, **kwargs)
            _pop_stack(THREAD_LOCAL)
            return result
        return func_wrapper
    return decorator


############################


@trace("specific sub system")
def remove_expired_pipelines():
    pass


@trace("remove invalid branches")
def remove_invalid_branches():
    pass


@trace("get all repos")
def get_all_repos():
    remove_invalid_branches()


@trace("get all pipelines")
def get_all_pipelines():
    remove_expired_pipelines()


def untraced_intermediate_layer():
    get_all_repos()
    get_all_pipelines()


@trace("inception")
def spawn_inception_handler():
    untraced_intermediate_layer()


def main():
    spawn_inception_handler()


if __name__ == "__main__":
    main()
