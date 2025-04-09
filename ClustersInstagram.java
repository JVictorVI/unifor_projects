import java.util.ArrayList;
import java.util.List;
import java.util.Stack;

class Vertice {

    String nome;
    List<Vertice> vizinhos;

    public Vertice(String nome) {
        this.nome = nome;
        this.vizinhos = new ArrayList<>();
    }

    public void adicionarVizinho(Vertice vertice) {
        vizinhos.add(vertice);
    }

    @Override
    public String toString() {
        return nome;
    }
}

class Grafo {

    private List<Vertice> vertices;

    public Grafo() {
        vertices = new ArrayList<>();
    }

    private Vertice buscarOuCriarVertice(String nome) {
        for (Vertice vertice : vertices) {
            if (vertice.nome.equals(nome)) {
                return vertice;
            }
        }
        Vertice novoVertice = new Vertice(nome);
        vertices.add(novoVertice);
        return novoVertice;
    }

    public void adicionarAresta(String origem, String destino) {
        Vertice vOrigem = buscarOuCriarVertice(origem);
        Vertice vDestino = buscarOuCriarVertice(destino);
        vOrigem.adicionarVizinho(vDestino);
    }

    public List<List<Vertice>> encontrarComponentesFortementeConectados() {

        // Pilha para armazenar a ordem de finalização dos vértices na primeira DFS.
        Stack<Vertice> pilha = new Stack<>();
    
        // Lista para marcar quais vértices já foram visitados.
        List<Vertice> visitado = new ArrayList<>();
    
        System.out.println("Primeira Etapa do Kosaraju - DFS\n");
    
        // Etapa 1: Realiza uma DFS no grafo original para preencher a pilha
        // com os vértices em ordem de término (últimos visitados no topo).
        for (Vertice vertice : vertices) {
            if (!visitado.contains(vertice)) {
                dfs(vertice, visitado, pilha); // DFS padrão
            }
        }
    
        System.out.println("\nPilha após a DFS: " + pilha);
    
        System.out.println("\nSegunda Etapa do Kosaraju - Criando Transposta do Grafo\n");
    
        // Etapa 2: Cria o grafo transposto (com todas as arestas invertidas).
        Grafo transposto = transporGrafo();
        transposto.printGrafo();
    
        // Limpa a lista de visitados para reutilizar na segunda DFS.
        visitado.clear();
    
        // Lista de componentes fortemente conectados (cada componente é uma lista de vértices).
        List<List<Vertice>> componentes_fortemente_conexos = new ArrayList<>();
    
        System.out.println("\nTerceira Etapa do Kosaraju - DFS no Grafo Transposto\n");
    
        // Etapa 3: Realiza uma nova DFS no grafo transposto, seguindo a ordem da pilha.
        // Cada DFS completa aqui corresponde a um componente fortemente conectado.
        while (!pilha.isEmpty()) {
    
            // Recupera o vértice correspondente no grafo transposto (pelos nomes).
            Vertice vertice = transposto.buscarVerticePorNome(pilha.pop().nome);
            System.out.println("Visitando " + vertice.nome + " na transposta");
    
            // Se o vértice ainda não foi visitado nesta DFS...
            if (!visitado.contains(vertice)) {
                // Cria uma nova lista para armazenar os vértices do componente atual.
                List<Vertice> componente = new ArrayList<>();
    
                // Realiza a DFS no grafo transposto e preenche o componente.
                dfsCriarComponente(vertice, visitado, componente);
    
                // Adiciona o componente à lista de componentes encontrados.
                componentes_fortemente_conexos.add(componente);   
            }
        }
    
        // Retorna todos os componentes fortemente conectados encontrados.
        return componentes_fortemente_conexos;
    }
    

    private void dfs(Vertice vertice, List<Vertice> visitado, Stack<Vertice> pilha) {
        
        visitado.add(vertice);
        System.out.println("Visitando " + vertice.nome);
        
        for (Vertice vizinho : vertice.vizinhos) {
            if (!visitado.contains(vizinho)) {
                dfs(vizinho, visitado, pilha);
            }
        }
        
        System.out.println("Adicionando " + vertice.nome + " na pilha");
        pilha.push(vertice);
    }

    private void dfsCriarComponente(Vertice vertice, List<Vertice> visitado, List<Vertice> componente) {
    
        // Marca o vértice atual como visitado para não revisitar.
        visitado.add(vertice);
    
        // Adiciona o vértice ao componente fortemente conectado atual.
        componente.add(vertice);
    
        // Percorre todos os vizinhos do vértice no grafo transposto.
        for (Vertice vizinho : vertice.vizinhos) {
            
            // Visita apenas os vértices que ainda não foram visitados.
            if (!visitado.contains(vizinho)) {
                // Chamada recursiva para explorar todo o componente.
                dfsCriarComponente(vizinho, visitado, componente);
            }
        }        
    }
    

    private Grafo transporGrafo() {
        Grafo transposto = new Grafo();
        for (Vertice vertice : vertices) {
            for (Vertice vizinho : vertice.vizinhos) {
                transposto.adicionarAresta(vizinho.nome, vertice.nome);
            }
        }
        return transposto;
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

    public Vertice buscarVerticePorNome(String nome) {
        for (Vertice vertice : vertices) {
            if (vertice.nome.equals(nome)) {
                return vertice;
            }
        }
        return null;
    }
}

public class ClustersInstagram {
    public static void main(String[] args) {

        Grafo g = new Grafo();

        g.adicionarAresta("Ana", "Beatriz");
        g.adicionarAresta("Beatriz", "Carlos");
        g.adicionarAresta("Carlos", "Ana");

        g.adicionarAresta("Carlos", "Daniel");
        g.adicionarAresta("Daniel", "Elisa");
        g.adicionarAresta("Elisa", "Felipe");
        g.adicionarAresta("Felipe", "Daniel");

        g.adicionarAresta("Gustavo", "Felipe");
        g.adicionarAresta("Helena", "Gustavo");

        System.out.println("Grafo inicial: \n");
        g.printGrafo();
        System.out.println();
        
        List<List<Vertice>> componentes = g.encontrarComponentesFortementeConectados();

        System.out.println("\nAgrupamentos identificados\n");
        for (int i = 0; i < componentes.size(); i++) {
            List<Vertice> grupo = componentes.get(i);
            System.out.print("Grupo " + (i + 1) + ": ");
            for (Vertice v : grupo) {
                System.out.print(v.nome + " ");
            }
            System.out.println();
        }
    }
}
