import os, subprocess, datetime, time, json, hashlib

print_ok = lambda message, output='', duration='': print("✅ \x1b[1;32m", message, "\x1b[0m⌚", datetime.datetime.now().time(), duration, "\n" if output else "", output)
print_info = lambda message: print("👉🏽 \x1b[1;34m", message, "\x1b[0m")
print_error = lambda message, output='', duration='': print("⛔ \x1b[1;31m", message, "\x1b[0m⌚", datetime.datetime.now().time(), duration, "\n" if output else "", output)
print_warning = lambda message, output='', duration='': print("⚠️ \x1b[1;33m", message, "\x1b[0m⌚", datetime.datetime.now().time(), duration, "\n" if output else "", output)
print_command = lambda command ='': print("⚙️ \x1b[1;34m Running: ", command, "\x1b[0m")
class Output(object):
    def __init__(self, success, text):
        self.success = success
        self.text = text
        try:
            self.json_data = json.loads(text)
        except:
            self.json_data = None
def run(command, ok_message = '', error_message = '', print_output = False, print_command_to_run = True):
    if print_command_to_run:
        print_command(command)
    start_time = time.time()
    try:
        output_text = subprocess.check_output(command, shell=True, stderr=subprocess.STDOUT).decode("utf-8")
        success = True
    except subprocess.CalledProcessError as e:
        output_text = e.output.decode("utf-8")
        success = False
    minutes, seconds = divmod(time.time() - start_time, 60)
    print_message = print_ok if success else print_error
    if (ok_message or error_message):
        print_message(ok_message if success else error_message, output_text if not success or print_output  else "", f"[{int(minutes)}m:{int(seconds)}s]")
    return Output(success, output_text)

def create_resource_group(create_resources, resource_group_name, resource_group_location):
    if not resource_group_name:
        print_warning('Please specify the resource group name')
    else:
        output = run(f"az group show --name {resource_group_name}")
        if create_resources:    
            if output.success:
                print_info(f"Using existing resource group '{resource_group_name}'")
            else:
                output = run(f"az group create --name {resource_group_name} --location {resource_group_location}", 
                                        f"Resource group '{resource_group_name}' created", 
                                        f"Failed to create the resource group '{resource_group_name}'")
        else:
            if output.success:
                print_info(f"Using resource group '{resource_group_name}'")
            else:
                print_error(f"Resource group '{resource_group_name}' does not exist")

def get_deployment_output(output, output_property, output_label = ''):
    try:       
        deployment_output = output.json_data['properties']['outputs'][output_property]['value'] 
        if output_label:
            print_info(f"{output_label}: {deployment_output}")
        return deployment_output
    except:
        print_error(f"Failed to retieve output property: '{output_property}'")
        return None
    
def print_response(response):
    print("Response headers: ", response.headers)
    if (response.status_code == 200):
        print_ok(f"Status Code: {response.status_code}")
        data = json.loads(response.text)
        print(json.dumps(data, indent=4))
    else:
        print_warning(f"Status Code: {response.status_code}")
        print(response.text)

def unique_string(input):
    return int(hashlib.sha256(input.encode('utf-8')).hexdigest(), 16) % 10**8

def file_string_interpolation(filename, source_path, target_path, **kwargs):
    with open(f"{source_path}/{filename}", 'r') as file:
        content = file.read().format(**kwargs)
    if not os.path.exists(target_path):
        os.makedirs(target_path)    
    with open(f"{target_path}/{filename}", 'w') as file:
        file.write(content)

