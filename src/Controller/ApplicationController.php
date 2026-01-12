<?php

namespace App\Controller;

use App\Entity\Application;
use App\Form\ApplicationType;
use App\Repository\ApplicationRepository;
use Doctrine\ORM\EntityManagerInterface;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Symfony\Component\Security\Http\Attribute\IsGranted;

#[Route('/application')]
#[IsGranted('ROLE_USER')] 
final class ApplicationController extends AbstractController
{
    #[Route(name: 'app_application_index', methods: ['GET'])]
    public function index(): Response
    {
        return $this->redirectToRoute('app_home');
    }

    #[Route('/new', name: 'app_application_new', methods: ['GET', 'POST'])]
    public function new(Request $request, EntityManagerInterface $entityManager): Response
    {
        $application = new Application();
        $form = $this->createForm(ApplicationType::class, $application);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $application->setUser($this->getUser()); 
            $entityManager->persist($application);
            $entityManager->flush();

            return $this->redirectToRoute('app_home', [], Response::HTTP_SEE_OTHER);
        }

        return $this->render('application/new.html.twig', [
            'application' => $application,
            'form' => $form,
        ]);
    }

// --- MÉTHODE CORRIGÉE AVEC LE BON NOM DE ROUTE ---
    #[Route('/{id}/update-status', name: 'app_application_update_status', methods: ['POST'])]
    public function updateStatus(Request $request, Application $application, EntityManagerInterface $entityManager): Response
    {
        $status = $request->request->get('status');
        $interviewDateStr = $request->request->get('interviewDate');

        if ($status) {
            $application->setStatus($status);
        }

        if ($interviewDateStr) {
            try {
                $application->setInterviewDate(new \DateTime($interviewDateStr));
            } catch (\Exception $e) {
                // Erreur de format ignorée
            }
        }

        $entityManager->flush();

        return $this->redirectToRoute('app_home');
    }

    
    #[Route('/{id}/edit', name: 'app_application_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, Application $application, EntityManagerInterface $entityManager): Response
    {
        $form = $this->createForm(ApplicationType::class, $application);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            $entityManager->flush();
            return $this->redirectToRoute('app_home', [], Response::HTTP_SEE_OTHER);
        }

        return $this->render('application/edit.html.twig', [
            'application' => $application,
            'form' => $form,
        ]);
    }

    #[Route('/{id}', name: 'app_application_delete', methods: ['POST'])]
    public function delete(Request $request, Application $application, EntityManagerInterface $entityManager): Response
    {
        if ($this->isCsrfTokenValid('delete'.$application->getId(), $request->getPayload()->getString('_token'))) {
            $entityManager->remove($application);
            $entityManager->flush();
        }

        return $this->redirectToRoute('app_home', [], Response::HTTP_SEE_OTHER);
    }
}