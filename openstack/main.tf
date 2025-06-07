# Tệp này được tạo ra với các lỗ hổng bảo mật cực kỳ nghiêm trọng.
# CHỈ DÙNG CHO MỤC ĐÍCH THỬ NGHIỆM VÀ DEMO KICS.
# *** TUYỆT ĐỐI KHÔNG SỬ DỤNG TRONG MÔI TRƯỜNG PRODUCTION. ***

terraform {
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.48.0"
    }
  }
}

# --- CÁC BIẾN GIẢ LẬP ---
# Các biến này chỉ để file có thể phân tích được, không cần giá trị thực.
variable "subnet_id" {
  default = "dummy-subnet-id"
}
variable "image_id" {
  default = "dummy-image-id"
}
variable "flavor_id" {
  default = "dummy-flavor-id"
}

# --- LỖ HỔNG SECURITY GROUP (HIGH) ---
# Vấn đề: Security Group cho phép truy cập SSH từ bất kỳ đâu trên Internet.
# Mức độ KICS: HIGH
# Giải thích: Mở cổng quản lý như SSH (22) ra 0.0.0.0/0 khiến máy chủ
# trở thành mục tiêu cho các cuộc tấn công brute-force tự động.
resource "openstack_networking_security_group_v2" "insecure_ssh_sg" {
  name        = "sg-allow-ssh-from-anywhere"
  description = "Security group that allows SSH from the entire internet"
}

resource "openstack_networking_security_group_rule_v2" "insecure_ssh_rule" {
  direction         = "ingress"
  ethertype         = "IPv4"
  protocol          = "tcp"
  port_range_min    = 22
  port_range_max    = 22
  remote_ip_prefix  = "0.0.0.0/0" # LỖ HỔNG NẰM Ở ĐÂY
  security_group_id = openstack_networking_security_group_v2.insecure_ssh_sg.id
}


# --- LỖ HỔNG MÁY ẢO (COMPUTE INSTANCE) VỚI CÁC LỖI CRITICAL VÀ HIGH ---

resource "openstack_compute_instance_v2" "vulnerable_instance" {
  name      = "extremely-vulnerable-vm"
  image_id  = var.image_id
  flavor_id = var.flavor_id

  # LỖ HỔNG 1 (HIGH): Gắn Security Group không an toàn vào máy ảo.
  # KICS sẽ thấy máy ảo này đang sử dụng security group mở cổng SSH ra toàn thế giới.
  security_groups = [
    openstack_networking_security_group_v2.insecure_ssh_sg.name
  ]

  network {
    # subnet_id được yêu cầu
    uuid = var.subnet_id
  }

  # LỖ HỔNG 2 (CRITICAL): Thông tin nhạy cảm (mật khẩu) được mã hóa cứng trong user_data.
  # Mức độ KICS: CRITICAL
  # Giải thích: user_data là một đoạn script khởi động chạy trên máy ảo.
  # Việc đặt mật khẩu, API key, hoặc bất kỳ bí mật nào ở đây dưới dạng văn bản thuần
  # là một rủi ro bảo mật cực kỳ nghiêm trọng.
  user_data = <<-EOF
    #!/bin/bash
    echo "Starting configuration..."
    # LỖ HỔNG NẰM Ở ĐÂY: Mật khẩu được mã hóa cứng
    export DATABASE_PASSWORD="SuperS3cretP@ssw0rdFromUserData!123"
    echo "Connecting to database with password: $DATABASE_PASSWORD"
    # ... các lệnh khác
  EOF
}

# --- LỖ HỔNG LOAD BALANCER (HIGH) ---
# Vấn đề: Load Balancer Listener sử dụng giao thức HTTP không mã hóa.
# Mức độ KICS: HIGH
# Giải thích: Dữ liệu truyền qua listener này (ví dụ: thông tin đăng nhập, dữ liệu cá nhân)
# không được mã hóa và có thể bị kẻ tấn công trên mạng bắt và đọc được (tấn công Man-in-the-Middle).
resource "openstack_lbaas_loadbalancer_v2" "lb" {
  name          = "insecure-lb"
  vip_subnet_id = var.subnet_id
}

resource "openstack_lbaas_listener_v2" "insecure_http_listener" {
  name            = "insecure-http-listener"
  protocol        = "HTTP" # LỖ HỔNG NẰM Ở ĐÂY: Phải là TERMINATED_HTTPS
  protocol_port   = 80
  loadbalancer_id = openstack_lbaas_loadbalancer_v2.lb.id
}

# ----------------------------------------

# Tệp này được tạo cho AWS để đảm bảo KICS phát hiện lỗi CRITICAL và HIGH.
# CHỈ DÙNG CHO MỤC ĐÍCH THỬ NGHIỆM.

# LỖ HỔNG CRITICAL: S3 Bucket cho phép bất kỳ ai cũng có thể đọc và GHI.
# Đây là lỗi cấu hình sai kinh điển và nguy hiểm nhất trên AWS.
# Nó cho phép bất kỳ ai trên Internet xóa, thay đổi, và tải lên dữ liệu của bạn.
resource "aws_s3_bucket" "data_storage" {
  bucket = "my-super-critical-data-bucket-12345"
}

resource "aws_s3_bucket_acl" "data_storage_acl" {
  bucket = aws_s3_bucket.data_storage.id
  
  # LỖ HỔNG CRITICAL NẰM Ở ĐÂY:
  acl    = "public-read-write" 
}


# LỖ HỔNG HIGH: Security Group cho phép truy cập SSH từ bất kỳ đâu.
# Mở cổng quản trị ra toàn bộ Internet là một rủi ro bảo mật cao,
# khiến máy chủ trở thành mục tiêu cho các cuộc tấn công brute-force.
resource "aws_security_group" "allow_all_ssh" {
  name        = "allow-all-ssh"
  description = "Allow SSH inbound traffic from anywhere"

  # LỖ HỔNG HIGH NẰM Ở ĐÂY:
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}