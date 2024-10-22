import pandas as pd
import random
import string

def generate_random_instruction_data(num_records):
    data = []
    
    for _ in range(num_records):
        # 随机生成命令名称（3个汉字）
        command_name = ''.join(random.choices('系统找不到指定的文件', k=3))
        # 随机生成命令代码（1到200之间的整数）
        command_code = random.randint(1, 200)
        # 随机生成命令内容（20个字符）
        command_content = ''.join(random.choices(string.ascii_letters + string.digits + ' ', k=20))
        # 随机生成描述（30个字符）
        description = ''.join(random.choices(string.ascii_letters + string.digits + ' ', k=30))
        
        # 将生成的数据添加到列表中
        data.append({
            "command_name": command_name,
            "command_code": command_code,
            "command_content": command_content,
            "description": description
        })
    
    return data

def save_to_csv(data, filename):
    # 将数据保存为CSV文件
    df = pd.DataFrame(data)
    df.to_csv(filename, index=False)
    
def save_to_excel(data, filename):
    # 将数据保存为Excel文件
    df = pd.DataFrame(data)
    with pd.ExcelWriter(filename, engine='openpyxl') as writer:
        df.to_excel(writer, index=False)

def generate_file_path(base_path, file_name, num_records):
    """生成完整的文件路径，文件名包含记录数量"""
    return f"{base_path}\\{file_name}_{num_records}.csv"

if __name__ == "__main__":
    num_records = 99999  # 指定生成的记录数量
    data = generate_random_instruction_data(num_records)
    
    # 定义文件导出地址
    base_path = 'D:\\desk\\code\\csv_excel_importer\\date'  # 基础路径
    csv_filename = generate_file_path(base_path, 'csv_date', num_records)  # CSV文件导出地址
    excel_filename = generate_file_path(base_path, 'excel_data', num_records).replace('.csv', '.xlsx')  # Excel文件导出地址
    
    # 保存生成的数据
    save_to_csv(data, csv_filename)
    save_to_excel(data, excel_filename)
