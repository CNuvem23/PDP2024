#!/bin/sh

# $1  = USER
# $2  = DISTRO (debian|alpine)
# $3  = N TIMES TO EXEC
# $4  = TIMESTAMP 
# $5* = OTHER benchmark-specific parameters

[ $5 ] || {
    echo ""
    echo "============================================="
    echo "[ERROR] trying to execute $0"
    echo "============================================="
    echo "    Missing <FILE_SIZE_IN_MB> parameter!"
    echo "============================================="
    echo ""
    exit
}

TIMESTAMP=$4

# Diretório onde serão salvos os resultados
result_dir="/cnuvem23/shared/"

# Número de vezes que o teste será executado
num_tests=$3

# Tamanho do arquivo de teste em MB
file_size_mb=$5

# Nome base para os arquivos de saída
output_base="outputs-iozone-$2-$TIMESTAMP"

# Variáveis para rastrear o tempo total e o tempo do teste mais longo
total_time=0
media_time=0
max_time=0
min_time=9999
desvio_padrao=0

# Nome do arquivo de saída em formato .txt
output_file="${result_dir}/$output_base-tempoGasto.txt"

# Inicializa o arquivo .xls com os cabeçalhos
echo "Test,Tempo (s)" > "$output_file"

# Loop para executar o teste iozone várias vezes
i=1
while [ "$i" -le "$num_tests" ]; do
    echo "Executando teste $i de $num_tests..."
    
    # Execute o teste iozone e redirecione a saída para um arquivo de saída
    start_time=$(date +%s.%N)
    iozone -i 0 -i 1 -s ${file_size_mb}M -r 4K > "${result_dir}/${output_base}_${i}.txt"
    end_time=$(date +%s.%N)

    #criando um arquivo com as estatísticas do relatório
    head -n 28 "${result_dir}/${output_base}_${i}.txt" | tail -n 1 >> ${result_dir}/${output_base}-estatistica.txt
    cat ${result_dir}/${output_base}-estatistica.txt

    # Calcule o tempo gasto neste teste
    test_time=$(echo "$end_time - $start_time" | bc)
    
    # Atualize o tempo total
    total_time=$(echo "$total_time + $test_time" | bc)

    # Verifique se este teste foi mais longo do que o anterior
    if [ "$(echo "$test_time > $max_time" | bc)" -eq 1 ]; then
        max_time=$test_time
    fi
    # Verifique se este teste foi mais curto do que o anterior
    if [ "$(echo "$test_time < $min_time" | bc)" -eq 1 ]; then
        min_time=$test_time
    fi
    echo "Teste $i concluído em $test_time microssegundos."
    
    # Adiciona os resultados ao arquivo .txt
    echo "$i,$test_time" >> "$output_file"

    i=$(( i + 1 ))
done

media_time=$(echo "scale=6; $total_time/$num_tests" | bc)
desvio_padrao=$(echo "scale=6; sqrt($media_time)" | bc -l)

# Exiba o tempo total gasto e o tempo do teste mais longo
echo "Tempo total gasto em microssegundos: $total_time"
echo "Tempo medio gasto em microssegundos: $media_time"
echo "Desvio padrão gasto em microssegundos: $desvio_padrao"
echo "Tempo do teste mais longo em microssegundos: $max_time"
echo "Tempo do teste mais curto em microssegundos: $min_time"
echo "Tempo total gasto em microssegundos: $total_time" >>"$output_file"
echo "Tempo medio gasto em microssegundos: $media_time" >>"$output_file"
echo "Desvio padrão gasto em microssegundos: $desvio_padrao" >>"$output_file"
echo "Tempo do teste mais longo em microssegundos: $max_time" >>"$output_file"
echo "Tempo do teste mais curto em microssegundos: $min_time" >>"$output_file"

echo "write" > ${result_dir}/${output_base}-resultados_finais.txt
echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
# Loop para executar o teste iozone várias vezes

# Calcular o maior valor na 3ª coluna
maior=$(awk '{print $3}' ${result_dir}/${output_base}-estatistica.txt | sort -n | tail -n 1)

# Calcular o menor valor na 3ª coluna
menor=$(awk '{print $3}' ${result_dir}/${output_base}-estatistica.txt | sort -n | head -n 1)

# Calcular a média dos valores na 3ª coluna
soma=$(awk '{s+=$3} END {print s}' ${result_dir}/${output_base}-estatistica.txt)
total_linhas=$(wc -l < ${result_dir}/${output_base}-estatistica.txt)
media=$(echo "$soma/$total_linhas" | bc)

# Calcular o desvio padrão dos valores na 3ª coluna
desvio_padrao=$(awk -v media="$media" '{s+=($3-media)^2} END {print sqrt(s/NR)}' ${result_dir}/${output_base}-estatistica.txt)

# Armazenar os resultados em outputs-iozone-resultados_finais.txt
echo "Maior valor: $maior" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Menor valor: $menor" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Média: $media" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Desvio Padrão: $desvio_padrao" >> ${result_dir}/${output_base}-resultados_finais.txt


echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "rewrite" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
# Loop para executar o teste iozone várias vezes

# Calcular o maior valor na 4ª coluna
maior=$(awk '{print $4}' ${result_dir}/${output_base}-estatistica.txt | sort -n | tail -n 1)

# Calcular o menor valor na 4ª coluna
menor=$(awk '{print $4}' ${result_dir}/${output_base}-estatistica.txt | sort -n | head -n 1)

# Calcular a média dos valores na 4ª coluna
soma=$(awk '{s+=$4} END {print s}' ${result_dir}/${output_base}-estatistica.txt)
total_linhas=$(wc -l < ${result_dir}/${output_base}-estatistica.txt)
media=$(echo "$soma/$total_linhas" | bc)

# Calcular o desvio padrão dos valores na 4ª coluna
desvio_padrao=$(awk -v media="$media" '{s+=($4-media)^2} END {print sqrt(s/NR)}' ${result_dir}/${output_base}-estatistica.txt)

# Armazenar os resultados em outputs-iozone-resultados_finais.txt
echo "Maior valor: $maior" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Menor valor: $menor" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Média: $media" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Desvio Padrão: $desvio_padrao" >> ${result_dir}/${output_base}-resultados_finais.txt


echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "read" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
# Loop para executar o teste iozone várias vezes

# Calcular o maior valor na 5ª coluna
maior=$(awk '{print $5}' ${result_dir}/${output_base}-estatistica.txt | sort -n | tail -n 1)

# Calcular o menor valor na 5ª coluna
menor=$(awk '{print $5}' ${result_dir}/${output_base}-estatistica.txt | sort -n | head -n 1)

# Calcular a média dos valores na 5ª coluna
soma=$(awk '{s+=$5} END {print s}' ${result_dir}/${output_base}-estatistica.txt)
total_linhas=$(wc -l < ${result_dir}/${output_base}-estatistica.txt)
media=$(echo "$soma/$total_linhas" | bc)

# Calcular o desvio padrão dos valores na 5ª coluna
desvio_padrao=$(awk -v media="$media" '{s+=($5-media)^2} END {print sqrt(s/NR)}' ${result_dir}/${output_base}-estatistica.txt)

# Armazenar os resultados em outputs-iozone-resultados_finais.txt
echo "Maior valor: $maior" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Menor valor: $menor" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Média: $media" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Desvio Padrão: $desvio_padrao" >> ${result_dir}/${output_base}-resultados_finais.txt


echo "#################################################" >>${result_dir}/${output_base}-resultados_finais.txt
echo "reread" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "#################################################" >> ${result_dir}/${output_base}-resultados_finais.txt
# Loop para executar o teste iozone várias vezes

# Calcular o maior valor na 6ª coluna
maior=$(awk '{print $6}' ${result_dir}/${output_base}-estatistica.txt | sort -n | tail -n 1)

# Calcular o menor valor na 6ª coluna
menor=$(awk '{print $6}' ${result_dir}/${output_base}-estatistica.txt | sort -n | head -n 1)

# Calcular a média dos valores na 6ª coluna
soma=$(awk '{s+=$6} END {print s}' ${result_dir}/${output_base}-estatistica.txt)
total_linhas=$(wc -l < ${result_dir}/${output_base}-estatistica.txt)
media=$(echo "$soma/$total_linhas" | bc)

# Calcular o desvio padrão dos valores na 6ª coluna
desvio_padrao=$(awk -v media="$media" '{s+=($6-media)^2} END {print sqrt(s/NR)}' ${result_dir}/${output_base}-estatistica.txt)

# Armazenar os resultados em outputs-iozone-resultados_finais.txt
echo "Maior valor: $maior" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Menor valor: $menor" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Média: $media" >> ${result_dir}/${output_base}-resultados_finais.txt
echo "Desvio Padrão: $desvio_padrao" >> ${result_dir}/${output_base}-resultados_finais.txt

echo "Resultados calculados e armazenados em ${result_dir}/${output_base}-resultados_finais.txt"

cat ${result_dir}/${output_base}-resultados_finais.txt
