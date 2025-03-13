import java.util.*;

class Vertice {
    String nome; // Nome do vértice
    List<Vertice> vizinhos; // Lista de vizinhos ligados ao vértice

    public Vertice(String nome) {
        this.nome = nome;
        this.vizinhos = new ArrayList<>(); 
    }

}

class Grafo {

    // Lista de vértices.
    private List<Vertice> vertices; 

    private boolean prevenirCiclo; // Define se o grafo pode ter ciclos ou não

    public Grafo(boolean prevenirCiclo) {
        this.vertices = new ArrayList<>();
        this.prevenirCiclo = prevenirCiclo;
    }

    public void adicionarVertice(String nome) {
        if (!verificarExistenciaVertice(nome)) { // Verifica se o vértice já existe no grafo
            vertices.add(new Vertice(nome)); // Adiciona apenas se não existir
        }
    }

    // Método para verificar se o vértice já foi adicionado no grafo
    private boolean verificarExistenciaVertice(String nome) {
        // Para cada vértice na lista de vértices, verifica se o nome é igual ao nome passado como parâmetro
        for (Vertice v : vertices) {
            // Se o vertice for encontrado com base no nome, retorna verdadeiro e não adiciona
            if (v.nome.equals(nome)) {
                return true;
            }
        }
        return false;
    }

    // Método para buscar um vértice pela nome
    private Vertice buscarVertice(String nome) {
        for (Vertice v : vertices) {
            if (v.nome.equals(nome)) {
                // Se o vértice for encontrado com base no nome, retorna o vértice
                return v;
            }
        }
        return null; // Retorna null caso o vértice não exista
    }

    public boolean adicionarAresta(String origem, String destino) {

        // Busca os vértices pelo nome e armazena na variável
        Vertice verticeOrigem = buscarVertice(origem);
        Vertice verticeDestino = buscarVertice(destino);

        // Verifica se os vértices existem no grafo
        if (verticeOrigem == null || verticeDestino == null) {
            System.out.println("Erro: Um dos nós não existe.");
            return false;
            
        }

        // Se for uma árvore de decisão, verifica ciclos antes de adicionar a aresta/ligação entre os vértices
        if (prevenirCiclo == true && DFS(verticeDestino, verticeOrigem)) {
            System.out.println("Erro: Ciclo detectado ao tentar conectar " + origem + " com " + destino);
            return false;

        }

        // Se permitir ciclos ou não houver ciclos, adiciona a aresta
        // Adiciona aos vizinhos do vértice de origem o vértice de destino
        verticeOrigem.vizinhos.add(verticeDestino);
        return true;

    }

    private boolean DFS(Vertice atual, Vertice alvo) {

        // Inicia a busca em profundidade (DFS) a partir do vértice de origem até o vértice de destino
        // O DFS é uma busca em profundidade que percorre todos os vértices de um grafo e seus vizinhos de forma recursiva
        // Se encontrar um ciclo, retorna true, caso contrário, retorna false
        
        // Se o vértice atual for o vértice de destino, encontrou um ciclo
        if (atual == alvo) return true;
        
        // Para cada vizinho do vértice atual, chama a função DFS recursivamente
        for (Vertice vizinho : atual.vizinhos) {
            // Se algum vizinho através da recursão, encontrar o vértice de destino, retorna true
            // Indicando que um ciclo foi encontrado
            if (DFS(vizinho, alvo)) {
                return true;
            }
        }
        // Se nenhum vizinho encontrar o vértice de destino, retorna false
        return false;
    }

    public void printGrafo() {
        for (Vertice vertice : vertices) {
            System.out.print(vertice.nome + " -> ");

            if (vertice.vizinhos.isEmpty()) {
                System.out.println( "FIM");
                continue; }

            for (Vertice vizinho : vertice.vizinhos) {
                System.out.print(vizinho.nome + " "); }
            
            System.out.println();
        }
    
    }
}

public class Main {
    public static void main(String[] args) {

        //////////// Fluxo de Atendimento ////////////
        
        Grafo fluxoAtendimento = new Grafo(false); // Não previne ciclos
        fluxoAtendimento.adicionarVertice("Triagem");
        fluxoAtendimento.adicionarVertice("Consulta");
        fluxoAtendimento.adicionarVertice("Exames");
        fluxoAtendimento.adicionarVertice("Diagnóstico");
        fluxoAtendimento.adicionarVertice("Tratamento");

        fluxoAtendimento.adicionarAresta("Triagem", "Consulta");
        fluxoAtendimento.adicionarAresta("Consulta", "Exames");
        fluxoAtendimento.adicionarAresta("Exames", "Diagnóstico");
        fluxoAtendimento.adicionarAresta("Diagnóstico", "Tratamento");
        
        System.out.println("Fluxo de Atendimento:");
        fluxoAtendimento.printGrafo();

        //Ciclo: O paciente pode precisar voltar para exames após o diagnóstico
        fluxoAtendimento.adicionarAresta("Diagnóstico", "Exames");

        System.out.println("\nFluxo de Atendimento após ciclo:");
        fluxoAtendimento.printGrafo();

        ///////////////// Árvore de Decisão /////////////////
        
        Grafo arvoreDecisao = new Grafo(true); // Não permite ciclos

        ////////////// VÉRTICES

        arvoreDecisao.adicionarVertice("Febre");

        arvoreDecisao.adicionarVertice("Tosse");
        arvoreDecisao.adicionarVertice("Náusea");
        
        arvoreDecisao.adicionarVertice("Falta de Ar");
        arvoreDecisao.adicionarVertice("Dor de Garganta");
        
        arvoreDecisao.adicionarVertice("Fraqueza");
        arvoreDecisao.adicionarVertice("Palpitações");
        
        arvoreDecisao.adicionarVertice("Pneumonia");
        arvoreDecisao.adicionarVertice("Gripe");
        
        arvoreDecisao.adicionarVertice("Pressão baixa");
        arvoreDecisao.adicionarVertice("Pressão alta");

        ////////////// CONEXÕES

        arvoreDecisao.adicionarAresta("Febre", "Tosse");
        arvoreDecisao.adicionarAresta("Febre", "Náusea");
        
        arvoreDecisao.adicionarAresta("Tosse", "Falta de Ar");
        arvoreDecisao.adicionarAresta("Falta de Ar", "Pneumonia");

        arvoreDecisao.adicionarAresta("Tosse", "Dor de Garganta");
        arvoreDecisao.adicionarAresta("Dor de Garganta", "Gripe");
        
        arvoreDecisao.adicionarAresta("Náusea", "Fraqueza");
        arvoreDecisao.adicionarAresta("Fraqueza", "Pressão baixa");

        arvoreDecisao.adicionarAresta("Náusea", "Palpitações");
        arvoreDecisao.adicionarAresta("Palpitações", "Pressão alta");
        
    
        System.out.println("\nÁrvore de Decisão: \n");
        arvoreDecisao.printGrafo();
        System.out.println();

        //Tentativa de adicionar um ciclo
        arvoreDecisao.adicionarAresta("Pneumonia", "Falta de Ar");
        
        //Outra tentativa de criação de ciclo
        //arvoreDecisao.adicionarAresta("Pneumonia", "Dor de Garganta");
        //arvoreDecisao.adicionarAresta("Gripe", "Pneumonia");

    }
}